export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="sorin"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# 加载 .rc（alias、函数、提示符）
[ -f "$HOME/.rc" ] && source "$HOME/.rc"
