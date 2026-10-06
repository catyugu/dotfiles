[[ $- == *i* ]] || return 0
[[ ${_DOTFILES_BASHRC_LOADED:-} != 1 ]] || return 0
_DOTFILES_BASHRC_LOADED=1

[[ ! -r "$HOME/.config/dotfiles/profile.sh" ]] || source "$HOME/.config/dotfiles/profile.sh"
if command -v fnm >/dev/null 2>&1 && [[ -z ${FNM_MULTISHELL_PATH:-} ]]; then
    eval "$(fnm env --shell bash)"
fi
source "$HOME/.config/dotfiles/rc.sh"
[[ ! -r "$HOME/.config/dotfiles/local.bash" ]] || source "$HOME/.config/dotfiles/local.bash"
