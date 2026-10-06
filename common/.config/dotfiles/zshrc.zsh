[[ -o interactive ]] || return 0
[[ ${_DOTFILES_ZSHRC_LOADED:-} != 1 ]] || return 0
_DOTFILES_ZSHRC_LOADED=1

[[ ! -r "$HOME/.config/dotfiles/profile.sh" ]] || source "$HOME/.config/dotfiles/profile.sh"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
# 已有入口若加载了 Oh My Zsh，避免重复加载。
if [[ -r "$ZSH/oh-my-zsh.sh" ]] && (( ! $+functions[omz] )); then
    ZSH_THEME="sorin"
    plugins=(git)
    for _dotfiles_plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$_dotfiles_plugin" ]]; then
            plugins+=("$_dotfiles_plugin")
        fi
    done
    unset _dotfiles_plugin
    source "$ZSH/oh-my-zsh.sh"
fi
source "$HOME/.config/dotfiles/rc.sh"
[[ ! -r "$HOME/.config/dotfiles/local.zsh" ]] || source "$HOME/.config/dotfiles/local.zsh"
