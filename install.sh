#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TARGET_DIR="$HOME"
ALLOWED_PACKAGES=(common nvim desktop)
PACKAGES=()
DRY_RUN=0
BACKUP=0
WITH_COMMON=0
CONFLICTS=()
ENTRY_NAMES=()
BACKUP_DIR=""
STAGE_DIR=""

usage() {
    cat <<'HELP'
Usage: ./install.sh [--dry-run] [--backup] [package ...]
Packages: common nvim desktop; default: common
  --dry-run   Inspect deployment without changing files
  --backup    Back up conflicting configs before replacing them
Shell entries remain local files. Existing contents are preserved.
HELP
}
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --backup) BACKUP=1 ;;
        -h|--help) usage; exit 0 ;;
        --*) die "Unknown option: $arg" ;;
        *)
            allowed=0
            for pkg in "${ALLOWED_PACKAGES[@]}"; do
                [[ "$arg" != "$pkg" ]] || allowed=1
            done
            (( allowed )) || die "Unknown package: $arg (allowed: ${ALLOWED_PACKAGES[*]})"
            duplicate=0
            for pkg in "${PACKAGES[@]}"; do
                [[ "$arg" != "$pkg" ]] || duplicate=1
            done
            (( duplicate )) || PACKAGES+=("$arg")
            ;;
    esac
done
(( ${#PACKAGES[@]} )) || PACKAGES=(common)
[[ -d "$TARGET_DIR" ]] || die "HOME must be an existing directory: $TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"
for cmd in stow find awk mktemp; do
    command -v "$cmd" >/dev/null 2>&1 || die "Missing dependency: $cmd; see README.md"
done
for pkg in "${PACKAGES[@]}"; do
    [[ -d "$DOTFILES_DIR/$pkg" ]] || die "Missing package directory: $pkg"
    [[ "$pkg" != common ]] || WITH_COMMON=1
done

# Keep this filter consistent with each package's .stow-local-ignore.
ignored() {
    [[ "$1" =~ (^|/)\.git(ignore|modules|attributes)?$ || "$1" =~ (^|/)\.stow-local-ignore$ ||
       "$1" =~ (^|/)(README(\.md)?|LICENSE)$ || "$1" =~ \.(swp|swo|orig|retry)$ ||
       "$1" =~ (^|/)\.DS_Store$ ]]
}
add_conflict() {
    local path="$1" existing
    for existing in "${CONFLICTS[@]}"; do
        [[ "$path" != "$existing" ]] || return 0
    done
    CONFLICTS+=("$path")
}

# Inspect parents too, to avoid writing through foreign directory symlinks.
for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r -d '' source; do
        relative="${source#"$DOTFILES_DIR/$pkg/"}"
        ignored "$relative" && continue
        parent="$relative"
        blocked=0
        while [[ "$parent" == */* ]]; do
            parent="${parent%/*}"
            target="$TARGET_DIR/$parent"
            if [[ -L "$target" ]]; then
                add_conflict "$parent"
                blocked=1
            elif [[ -e "$target" && ! -d "$target" ]]; then
                add_conflict "$parent"
                blocked=1
            fi
        done
        (( blocked )) && continue
        target="$TARGET_DIR/$relative"
        if [[ -e "$target" || -L "$target" ]]; then
            if [[ ! -L "$target" || ! "$target" -ef "$source" ]]; then
                add_conflict "$relative"
            fi
        fi
    done < <(find "$DOTFILES_DIR/$pkg" \( -type f -o -type l \) -print0)
done

printf 'Packages: %s\nTarget: %s\n' "${PACKAGES[*]}" "$TARGET_DIR"
if (( ${#CONFLICTS[@]} )); then
    printf 'Conflicting paths:\n'
    printf '  %s\n' "${CONFLICTS[@]}"
    (( BACKUP )) || die "No files changed. Compare these files, then use --backup to replace them."
fi
ensure_backup_dir() {
    if [[ -z "$BACKUP_DIR" ]]; then
        mkdir -p "$TARGET_DIR/.local/state/dotfiles/backups"
        BACKUP_DIR="$(mktemp -d "$TARGET_DIR/.local/state/dotfiles/backups/$(date +%Y%m%d-%H%M%S).XXXXXX")"
        chmod 700 "$BACKUP_DIR"
        printf 'Backup: %s\n' "$BACKUP_DIR"
    fi
}
backup_copy() {
    local relative="$1"
    ensure_backup_dir
    mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
    cp -pP "$TARGET_DIR/$relative" "$BACKUP_DIR/$relative"
}

# Prepare every entry before touching the target.
if (( WITH_COMMON )); then
    STAGE_DIR="$(mktemp -d)"
    trap '[[ -z "$STAGE_DIR" ]] || rm -rf "$STAGE_DIR"' EXIT
    bash_login=.bash_profile
    if [[ ! -e "$TARGET_DIR/.bash_profile" && ! -L "$TARGET_DIR/.bash_profile" && -e "$TARGET_DIR/.bash_login" ]]; then
        bash_login=.bash_login
    fi
    ENTRY_NAMES=(.profile .bashrc .zshrc "$bash_login" .zprofile)
    for entry in "${ENTRY_NAMES[@]}"; do
        target="$TARGET_DIR/$entry"
        if [[ -L "$target" ]]; then
            (( BACKUP )) || die "$entry is a symlink; use --backup to preserve its contents as a local file."
            [[ -f "$target" ]] || die "Cannot read symlink: $entry"
        fi
        [[ ! -d "$target" ]] || die "Shell entry is a directory: $entry"
        staged="$STAGE_DIR/$entry"
        if [[ ! -e "$target" ]]; then
            : > "$staged"
            case "$entry" in
                .bash_profile|.bash_login)
                    printf '[ ! -r "$HOME/.profile" ] || . "$HOME/.profile"\n[ ! -r "$HOME/.bashrc" ] || . "$HOME/.bashrc"\n' >> "$staged" ;;
                .zprofile)
                    printf '[ ! -r "$HOME/.profile" ] || . "$HOME/.profile"\n' >> "$staged" ;;
            esac
            chmod 600 "$staged"
        else
            cp -pL "$target" "$staged"
        fi
        # Remove only our exact marker pair. Refuse malformed blocks.
        awk '
            $0 == "# >>> dotfiles >>>" { if (inside || seen++) exit 2; inside=1; next }
            $0 == "# <<< dotfiles <<<" { if (!inside) exit 2; inside=0; next }
            !inside { print }
            END { if (inside) exit 2 }
        ' "$staged" > "$STAGE_DIR/blockless" || die "Malformed or duplicate dotfiles markers in $entry"
        cat "$STAGE_DIR/blockless" > "$staged"
        {
            printf '# >>> dotfiles >>>\n'
            case "$entry" in
                .profile|.zprofile) config=profile.sh ;;
                .bashrc) config=bashrc.bash ;;
                .zshrc) config=zshrc.zsh ;;
                .bash_profile|.bash_login) config=profile.sh ;;
            esac
            printf '[ ! -r "$HOME/.config/dotfiles/%s" ] || . "$HOME/.config/dotfiles/%s"\n' "$config" "$config"
            if [[ "$entry" == .bash_profile || "$entry" == .bash_login ]]; then
                printf '[ ! -r "$HOME/.config/dotfiles/bashrc.bash" ] || . "$HOME/.config/dotfiles/bashrc.bash"\n'
            fi
            printf '# <<< dotfiles <<<\n'
        } >> "$staged"
    done
fi

STOW_ARGS=(--restow --no-folding --dir="$DOTFILES_DIR" --target="$TARGET_DIR")
if (( DRY_RUN )); then
    if (( ${#CONFLICTS[@]} )); then
        printf 'Would back up conflicts before deployment.\n'
    else
        stow --simulate "${STOW_ARGS[@]}" "${PACKAGES[@]}"
    fi
    for entry in "${ENTRY_NAMES[@]}"; do
        if [[ -L "$TARGET_DIR/$entry" ]] || ! cmp -s "$STAGE_DIR/$entry" "$TARGET_DIR/$entry"; then
            printf 'Would back up existing entry and update: %s\n' "$entry"
        fi
    done
    printf 'Dry run complete; no target files changed.\n'
    exit 0
fi

# Keep only outermost blockers so backups never follow foreign symlinks.
for relative in "${CONFLICTS[@]}"; do
    nested=0
    for other in "${CONFLICTS[@]}"; do
        [[ "$relative" != "$other/"* ]] || nested=1
    done
    (( nested )) && continue
    ensure_backup_dir
    mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
    mv "$TARGET_DIR/$relative" "$BACKUP_DIR/$relative"
done
stow --simulate "${STOW_ARGS[@]}" "${PACKAGES[@]}"
stow "${STOW_ARGS[@]}" "${PACKAGES[@]}"
for entry in "${ENTRY_NAMES[@]}"; do
    target="$TARGET_DIR/$entry"
    if [[ ! -L "$target" ]] && cmp -s "$STAGE_DIR/$entry" "$target"; then
        continue
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        backup_copy "$entry"
    fi
    mv "$STAGE_DIR/$entry" "$target"
done
printf 'Done. Open a new shell to load the configuration.\n'
if (( WITH_COMMON )); then
    [[ -r "$TARGET_DIR/.oh-my-zsh/oh-my-zsh.sh" ]] || printf 'Optional: install Oh My Zsh for the Zsh theme/plugins (see README.md).\n'
fi
for pkg in "${PACKAGES[@]}"; do
    case "$pkg" in
        nvim) command -v nvim >/dev/null 2>&1 || printf 'Missing application: nvim (see README.md).\n' ;;
        desktop) printf 'Desktop dependencies are listed in README.md; enable session setup as needed.\n' ;;
    esac
done
