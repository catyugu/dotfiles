# 公共环境配置：供 POSIX sh、Bash 和 Zsh 加载。
# 登录入口与交互入口可能都加载本文件；同一 shell 中只初始化一次。
if [ "${_DOTFILES_PROFILE_LOADED:-}" != 1 ]; then
    _DOTFILES_PROFILE_LOADED=1
    if [ -d "$HOME/.local/bin" ]; then
        case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) PATH="$HOME/.local/bin:$PATH" ;;
        esac
    fi
    export PATH
    if [ -r "$HOME/.config/dotfiles/local.sh" ]; then
        . "$HOME/.config/dotfiles/local.sh"
    fi
fi
