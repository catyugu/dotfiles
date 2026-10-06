# 公共环境配置：供 POSIX sh、Bash 和 Zsh 加载。
# 登录入口与交互入口可能都加载本文件；同一 shell 中只初始化一次。
if [ "${_DOTFILES_PROFILE_LOADED:-}" != 1 ]; then
    _DOTFILES_PROFILE_LOADED=1
    for _dotfiles_bin in "$HOME/.local/bin" "$HOME/.bun/bin" "$HOME/.local/share/fnm"; do
        if [ -d "$_dotfiles_bin" ]; then
            case ":$PATH:" in
                *":$_dotfiles_bin:"*) ;;
                *) PATH="$_dotfiles_bin:$PATH" ;;
            esac
        fi
    done
    export PATH
    unset _dotfiles_bin
    if [ -r "$HOME/.config/dotfiles/local.sh" ]; then
        . "$HOME/.config/dotfiles/local.sh"
    fi
fi
