#!/bin/bash

set -euo pipefail  # Strikte Fehlerbehandlung

# WARNUNG: Dieses Skript sichert auch sensible Daten (SSH-Keys, GPG, Browser, Passwortmanager etc.)!
# SICHERE SENSIBLE DATEIEN NIEMALS IN EIN ÖFFENTLICHES REPOSITORY!
# Nach dem Backup wird eine .gitignore mit allen sensiblen Pfaden im Backup-Ordner erzeugt.

# Verzeichnisstruktur
DOTFILES_DIR="${HOME}/dotfiles"                     # Git-Repository (ohne Datum)
BACKUP_ROOT="${HOME}/dotfiles_backups"              # Separate Backups
BACKUP_DIR="${BACKUP_ROOT}/$(date +%Y-%m-%d)"      # Backup mit Datum

# Liste SENSIBLER Dateien/Verzeichnisse die NICHT auf GitHub sollen
# Nur hier eintragen, was wirklich sensibel ist!
sensitive_paths=(
    # Authentifizierung & Sicherheit
    ".ssh"
    ".gnupg"
    ".pki"
    # Browser-Profile (enthalten Passwörter/Cookies)
    ".mozilla"
    ".config/BraveSoftware"
    ".config/chromium"
    ".config/google-chrome"
    ".config/microsoft-edge"
    ".config/vivaldi"
    # Passwort-Manager
    ".config/keepassxc"
    # Zugangsdaten & Tokens
    ".config/Code/User/globalStorage"    # VS Code Tokens
    ".config/Code/User/sync"            # VS Code Sync-Daten
    ".config/gh/hosts.yml"              # GitHub Tokens
    ".config/github-copilot"            # Copilot Tokens
    # Entwicklungsumgebungen mit Auth-Daten
    ".dotnet"                           # .NET Credentials
    ".config/containers/auth.json"      # Container Registry Auth
)

# Array für Dotfiles
# Passe die Liste nach Bedarf an
dotfiles=(
    ".zshenv"
    ".zshrc"
    ".gitconfig"
    ".gtkrc-2.0"
    ".gtkrc-2.0-kde4"
)

# Array für Dot-Verzeichnisse
# Passe die Liste nach Bedarf an
dotdirs=(
    ".themes"
)

# Array für Verzeichnisse in ~/.config
configdirs=(
    "btop"
    "Code" # Hinzugefügt für VS Code
    "gtk-3.0"
    "gtk-4.0"
    "kitty"
    "lazygit"
    "nvim"
    "ohmyposh"
    "yazi"
    "zsh"
)

# Array für Verzeichnisse in ~/.local
localdirs=(
    "myscripts"
)

# Funktion: .gitignore für sensible Daten erzeugen
create_gitignore() {
    local gitignore="${DOTFILES_DIR}/.gitignore"
    local tmpfile
    tmpfile="$(mktemp)" || return 1

    {
        # Header
        printf '# SENSIBLE DATEIEN/VERZEICHNISSE – NICHT AUF GITHUB PUSHEN!\n\n'

        # Backups ausschließen (relativ zum Git-Repository)
        printf '# Backup-Verzeichnisse\n'
        printf '../dotfiles_backups/\n\n'

        # Sensible Pfade eintragen (ohne Duplikate)
        printf '# Sensible Daten\n'
        printf '%s\n' "${sensitive_paths[@]}" | sort -u

        # Hinweis
        printf '\n# Diese .gitignore schützt sensible Daten vor versehentlichem Push.\n'
        printf '# Ergänze bei Bedarf weitere sensible Dateien/Ordner.\n'
    } > "${tmpfile}" || return 1

    # Atomarer Move der fertigen Datei
    mv "${tmpfile}" "${gitignore}" || return 1
    printf '.gitignore wurde erstellt in %s\n' "${DOTFILES_DIR}"
}

# Hilfsfunktionen
create_dir() {
    local dir="$1"
    if ! mkdir -p "$dir"; then
        printf "Fehler beim Erstellen von %s\n" "$dir" >&2
        return 1
    fi
}

safe_copy() {
    local src="$1" dst="$2"
    if ! cp -a "$src" "$dst" 2>/dev/null; then
        printf "Warnung: Konnte %s nicht nach %s kopieren\n" "$src" "$dst" >&2
        return 1
    fi
}

# Verzeichnisse anlegen
create_dir "${DOTFILES_DIR}" || exit 1
create_dir "${BACKUP_DIR}" || exit 1

# Dotfiles sichern (in beide Verzeichnisse)
for file in "${dotfiles[@]}"; do
    if [[ -e ${HOME}/${file} ]]; then
        safe_copy "${HOME}/${file}" "${DOTFILES_DIR}/" || continue
        safe_copy "${HOME}/${file}" "${BACKUP_DIR}/" || continue
    fi
done

# Dot-Verzeichnisse sichern
for dir in "${dotdirs[@]}"; do
    if [[ -d ${HOME}/${dir} ]]; then
        safe_copy "${HOME}/${dir}" "${DOTFILES_DIR}/" || continue
        safe_copy "${HOME}/${dir}" "${BACKUP_DIR}/" || continue
    fi
done

# ~/.config-Unterverzeichnisse sichern
create_dir "${DOTFILES_DIR}/.config"
create_dir "${BACKUP_DIR}/.config"

for cdir in "${configdirs[@]}"; do
    if [[ "$cdir" = "Code" ]]; then
        # Nur settings.json und keybindings.json sichern
        create_dir "${DOTFILES_DIR}/.config/Code/User"
        create_dir "${BACKUP_DIR}/.config/Code/User"
        for f in settings.json keybindings.json; do
            if [[ -f "${HOME}/.config/Code/User/${f}" ]]; then
                safe_copy "${HOME}/.config/Code/User/${f}" "${DOTFILES_DIR}/.config/Code/User/" || continue
                safe_copy "${HOME}/.config/Code/User/${f}" "${BACKUP_DIR}/.config/Code/User/" || continue
            fi
        done
    elif [[ -d "${HOME}/.config/${cdir}" ]]; then
        safe_copy "${HOME}/.config/${cdir}" "${DOTFILES_DIR}/.config/" || continue
        safe_copy "${HOME}/.config/${cdir}" "${BACKUP_DIR}/.config/" || continue
    fi
done

# ~/.local-Unterverzeichnisse sichern
create_dir "${DOTFILES_DIR}/.local"
create_dir "${BACKUP_DIR}/.local"

for ldir in "${localdirs[@]}"; do
    if [[ -d "${HOME}/.local/${ldir}" ]]; then
        safe_copy "${HOME}/.local/${ldir}" "${DOTFILES_DIR}/.local/" || continue
        safe_copy "${HOME}/.local/${ldir}" "${BACKUP_DIR}/.local/" || continue
    fi
done

# Spezielles Backup für ~/.homatxt nur in das Backup-Verzeichnis
if [[ -d "${HOME}/.homatxt" ]]; then
    printf '%s\n' "Sichere ~/.homatxt nur in das Backup-Verzeichnis..."
    safe_copy "${HOME}/.homatxt" "${BACKUP_DIR}/" || true
fi

# .gitignore für sensible Daten erzeugen
create_gitignore

printf "Dotfiles für Git gesichert in: %s\n" "$DOTFILES_DIR"
printf "Backup mit Datum erstellt in: %s\n" "$BACKUP_DIR"
