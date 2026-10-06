case $- in
    *i*) ;;
    *) return 0 ;;
esac
[ "${_DOTFILES_ZSHRC_LOADED:-}" != 1 ] || return 0
_DOTFILES_ZSHRC_LOADED=1

[ ! -r "$HOME/.config/dotfiles/profile.sh" ] || . "$HOME/.config/dotfiles/profile.sh"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [ -r "$ZSH/oh-my-zsh.sh" ]; then
    # 已有入口若加载了 Oh My Zsh，避免重复加载。
    if ! command -v omz >/dev/null 2>&1; then
        ZSH_THEME="sorin"
        plugins=(git)
        for _dotfiles_plugin in zsh-autosuggestions zsh-syntax-highlighting; do
            if [ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$_dotfiles_plugin" ]; then
                plugins+=("$_dotfiles_plugin")
            fi
        done
        unset _dotfiles_plugin
        . "$ZSH/oh-my-zsh.sh"
    fi
fi
. "$HOME/.config/dotfiles/rc.sh"
[ ! -r "$HOME/.config/dotfiles/local.zsh" ] || . "$HOME/.config/dotfiles/local.zsh"
