-- @version 2
-- A plugin to mount, unmount, and eject partitions.
--
-- This is an updated version of the original mount plugin, rewritten to use
-- modern, asynchronous Yazi APIs.

local async = require("yazi-plugin.async")
local child_process = require("yazi-plugin.child_process")
local event = require("yazi-plugin.event")

local M = {
	keys = {
		{ on = "q", run = "quit", desc = "Quit the mount manager" },

		{ on = "k", run = "up", desc = "Move cursor up" },
		{ on = "j", run = "down", desc = "Move cursor down" },
		{ on = "l", run = { "enter", "quit" }, desc = "Enter the selected mount point" },

		{ on = "<Up>", run = "up", desc = "Move cursor up" },
		{ on = "<Down>", run = "down", desc = "Move cursor down" },
		{ on = "<Right>", run = { "enter", "quit" }, desc = "Enter the selected mount point" },

		{ on = "m", run = "mount", desc = "Mount the selected partition" },
		{ on = "u", run = "unmount", desc = "Unmount the selected partition" },
		{ on = "e", run = "eject", desc = "Eject the selected device" },
	},
	partitions = {},
	cursor = 0,
	visible = false,
}

function M:new(area)
	self:layout(area)
	return self
end

function M:layout(area)
	local main_chunks = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(10),
			ui.Constraint.Percentage(80),
			ui.Constraint.Percentage(10),
		})
		:split(area)

	local chunks = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Percentage(10),
			ui.Constraint.Percentage(80),
			ui.Constraint.Percentage(10),
		})
		:split(main_chunks[2])

	self._area = chunks[2]
end

function M:entry(job)
	if job.args[1] == "refresh" then
		return self:update_partitions(self:obtain())
	end

	self:toggle_ui()
	if not self.visible then
		return
	end

	self:update_partitions(self:obtain())
	self:subscribe()

	async.run(function()
		while self.visible do
			local result = Yazi.which({ cands = self.keys, silent = true })
			if not result then
				break
			end

			local cand = self.keys[result] or { run = {} }
			local runs = type(cand.run) == "table" and cand.run or { cand.run }

			for _, r in ipairs(runs) do
				if r == "quit" then
					self:toggle_ui()
					break
				elseif r == "up" then
					self:update_cursor(-1)
				elseif r == "down" then
					self:update_cursor(1)
				elseif r == "enter" then
					local active = self:active_partition()
					if active and active.dist then
						Yazi:cd(active.dist)
					end
				elseif r == "mount" then
					self:operate("mount")
				elseif r == "unmount" then
					self:operate("unmount")
				elseif r == "eject" then
					self:operate("eject")
				end
			end
		end
		self:toggle_ui() -- Ensure UI is hidden on break
	end)
end

function M:toggle_ui()
	self.visible = not self.visible
	if self.visible then
		Yazi.modal_show(self)
	else
		Yazi.modal_hide()
	end
	Yazi.render()
end

function M:subscribe()
	event.off("mount") -- Unsubscribe from previous listeners
	event.on("mount", function()
		Plugin:emit("refresh")
	end)
end

function M:update_partitions(partitions)
	self.partitions = partitions
	if #self.partitions == 0 then
		self.cursor = 0
	else
		self.cursor = math.max(0, math.min(self.cursor or 0, #self.partitions - 1))
	end
	Yazi.render()
end

function M:active_partition()
	return self.partitions[self.cursor + 1]
end

function M:update_cursor(delta)
	if #self.partitions == 0 then
		self.cursor = 0
	else
		self.cursor = ya.clamp(0, self.cursor + delta, #self.partitions - 1)
	end
	Yazi.render()
end

function M:operate(op_type)
	local active = self:active_partition()
	if not active then
		return self:fail("No active partition selected.")
	end
	if not active.sub then
		return self:fail("Operating on main disks is not supported.")
	end

	async.run(function()
		local result
		if Yazi.target_os == "macos" then
			result = child_process.command({ "diskutil", op_type, active.src })
		elseif Yazi.target_os == "linux" then
			if op_type == "eject" then
				child_process.command({ "udisksctl", "unmount", "-b", active.src })
				result = child_process.command({ "udisksctl", "power-off", "-b", active.src })
			else
				result = child_process.command({ "udisksctl", op_type, "-b", active.src })
			end
		else
			return self:fail("Unsupported OS for mount operations.")
		end

		if not result or not result.status.success then
			self:fail("Failed to %s `%s`: %s", op_type, active.src, result and result.stderr or "Unknown error")
		else
			Plugin:emit("refresh")
		end
	end)
end

function M:fail(s, ...)
	Yazi.notify({
		title = "Mount",
		content = string.format(s, ...),
		timeout = 10,
		level = "error",
	})
end

function M:reflow()
	return { self }
end

function M:redraw()
	local rows = {}
	for _, p in ipairs(self.partitions or {}) do
		if not p.sub then
			rows[#rows + 1] = ui.Row({ p.main })
		elseif p.sub == "" then
			rows[#rows + 1] = ui.Row({ p.main, p.label or "", p.dist or "", p.fstype or "" })
		else
			rows[#rows + 1] = ui.Row({ "  " .. p.sub, p.label or "", p.dist or "", p.fstype or "" })
		end
	end

	return {
		ui.Clear(self._area),
		ui.Border(ui.Border.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style().fg("blue"))
			:title(ui.Line("Mount"):align(ui.Line.CENTER)),
		ui.Table(rows)
			:area(self._area:pad(ui.Pad(1, 2, 1, 2)))
			:header(ui.Row({ "Src", "Label", "Dist", "FSType" }):style(ui.Style().bold()))
			:row(self.cursor)
			:row_style(ui.Style().fg("blue"):underline())
			:widths({
				ui.Constraint.Length(20),
				ui.Constraint.Length(20),
				ui.Constraint.Percentage(70),
				ui.Constraint.Length(10),
			}),
	}
end

function M:obtain()
	local tbl = {}
	local last
	for _, p in ipairs(fs.partitions()) do
		local main, sub = self:split(p.src)
		if main and last ~= main then
			if p.src == main then
				last, p.main, p.sub, tbl[#tbl + 1] = p.src, p.src, "", p
			else
				last, tbl[#tbl + 1] = main, { src = main, main = main, sub = "" }
			end
		end
		if sub then
			if tbl[#tbl].sub == "" and tbl[#tbl].main == main then
				tbl[#tbl].sub = nil
			end
			p.main, p.sub, tbl[#tbl + 1] = main, sub, p
		end
	end
	table.sort(self:fillin(tbl), function(a, b)
		if a.main == b.main then
			return (a.sub or "") < (b.sub or "")
		else
			return a.main > b.main
		end
	end)
	return tbl
end

function M:split(src)
	local pats = {
		{ "^/dev/sd[a-z]", "%d+$" }, -- /dev/sda1
		{ "^/dev/nvme%d+n%d+", "p%d+$" }, -- /dev/nvme0n1p1
		{ "^/dev/mmcblk%d+", "p%d+$" }, -- /dev/mmcblk0p1
		{ "^/dev/disk%d+", ".+$" }, -- /dev/disk1s1
	}
	for _, p in ipairs(pats) do
		local main = src:match(p[1])
		if main then
			return main, src:sub(#main + 1):match(p[2])
		end
	end
end

function M:fillin(tbl)
	if Yazi.target_os ~= "linux" then
		return tbl
	end

	local sources, indices = {}, {}
	for i, p in ipairs(tbl) do
		if p.sub and not p.fstype then
			sources[#sources + 1], indices[p.src] = p.src, i
		end
	end
	if #sources == 0 then
		return tbl
	end

	local result = async.sync(function()
		return child_process.command({ "lsblk", "-p", "-o", "name,fstype", "-J", unpack(sources) })
	end)

	if not result.status.success then
		Yazi.log_debug("Failed to fetch filesystem types for unmounted partitions: " .. result.stderr)
		return tbl
	end

	local t = Yazi.json_decode(result.stdout or "")
	if t and t.blockdevices then
		for _, p in ipairs(t.blockdevices) do
			if indices[p.name] then
				tbl[indices[p.name]].fstype = p.fstype
			end
		end
	end
	return tbl
end

function M:click() end
function M:scroll() end
function M:touch() end

return M