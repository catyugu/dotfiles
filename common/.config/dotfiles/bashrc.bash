case $- in
    *i*) ;;
    *) return 0 ;;
esac
[ "${_DOTFILES_BASHRC_LOADED:-}" != 1 ] || return 0
_DOTFILES_BASHRC_LOADED=1

[ ! -r "$HOME/.config/dotfiles/profile.sh" ] || . "$HOME/.config/dotfiles/profile.sh"
. "$HOME/.config/dotfiles/rc.sh"
[ ! -r "$HOME/.config/dotfiles/local.bash" ] || . "$HOME/.config/dotfiles/local.bash"
