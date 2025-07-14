#!/bin/bash

# Hilfsfunktion zum Prüfen, ob ein Befehl existiert
is_installed() {
  command -v "$1" &> /dev/null
}

# Hilfsfunktion für Fedora-Pakete
is_rpm_installed() {
  rpm -q "$1" &> /dev/null
}

# 1. mise Installation prüfen
if ! is_installed mise; then
    echo "Installing mise..."
    curl https://mise.run | sh

    # shellcheck disable=SC2016
    echo 'eval "$(mise activate)"' >> ~/.bashrc
    # shellcheck disable=SC2016
    echo 'eval "$(mise activate)"' >> ~/.zshrc
    # shellcheck disable=SC2016
    echo 'eval "$(mise activate)"' >> ~/.config/fish/config.fish
else
    echo "mise ist bereits installiert."
fi

# 2. Fedora-Pakete prüfen/installieren (nur falls nicht vorhanden)
FEDORA_PKGS=(neovim nodejs npm python3 python3-pip go ripgrep fd-find fzf lazygit ruby yarn nodejs-bash-language-server)
for pkg in "${FEDORA_PKGS[@]}"; do
  if ! is_rpm_installed "$pkg"; then
    echo "Installiere Fedora-Paket: $pkg"
    sudo dnf install -y "$pkg"
  else
    echo "$pkg ist bereits installiert."
  fi
done

# 3. Tools mit mise installieren (ohne neovim, node, go, ruby, yarn, ffmpeg, fzf, lazygit, da über Fedora)
echo "Installing tools with mise (nur falls nicht vorhanden)..."
for tool in bat@latest black@latest bun@latest delta@latest deno@latest lua-language-server@latest rg@latest ruff@latest rye@latest stylua@latest usage@latest uv@latest; do
  tool_name=$(echo $tool | cut -d'@' -f1)
  if ! is_installed "$tool_name"; then
    mise install $tool
  else
    echo "$tool_name ist bereits installiert."
  fi
done

# 4. Go-Tools
if is_installed go; then
  echo "Installing Go tools..."
  go install golang.org/x/tools/gopls@latest
  go install github.com/mgechev/revive@latest
  go install mvdan.cc/sh/v3/cmd/shfmt@latest
else
  echo "Go nicht gefunden, Go-Tools werden übersprungen."
fi

# 5. NPM Pakete
if is_installed npm; then
  echo "Installing npm packages (verbose mode)..."
  sudo npm install -g --verbose \
    @google/gemini-cli \
    @antfu/ni \
    @fsouza/prettierd \
    @mermaid-js/mermaid-cli \
    @tailwindcss/language-server \
    @vtsls/language-server \
    bash-language-server \
    cspell \
    oxlint \
    pnpm \
    prettier \
    rustywind \
    typescript-language-server \
    typescript \
    vscode-langservers-extracted
else
  echo "npm nicht gefunden, npm Pakete werden übersprungen."
fi

# 6. Python Tools mit uv (optional)
if is_installed uv; then
  echo "Installing Python tools with uv..."
  for pytool in codespell isort pyright ruff; do
    if ! uv tool list | grep -q "^$pytool "; then
      uv tool install $pytool
    else
      echo "$pytool ist bereits mit uv installiert."
    fi
  done
else
  echo "uv nicht gefunden, versuche automatische Installation mit mise..."
  if is_installed mise; then
    mise install uv@latest
    if is_installed uv; then
      echo "uv erfolgreich installiert. Installing Python tools with uv..."
      for pytool in codespell isort pyright ruff; do
        if ! uv tool list | grep -q "^$pytool "; then
          uv tool install $pytool
        else
          echo "$pytool ist bereits mit uv installiert."
        fi
      done
    else
      echo "Automatische Installation von uv fehlgeschlagen. Bitte installiere uv manuell mit 'pip install uv' oder 'mise install uv'."
    fi
  else
    echo "mise nicht gefunden. Bitte installiere uv manuell mit 'pip install uv' oder 'mise install uv'."
  fi
fi

echo "Alle Tools wurden installiert oder waren bereits vorhanden."

echo "--- Postinstall-Hinweis ---"
echo "Folgende Fedora-Pakete wurden ggf. manuell installiert oder waren schon vorhanden:"
echo "${FEDORA_PKGS[@]}"
echo "Bitte prüfe, ob alle Tools wie gewünscht funktionieren."
