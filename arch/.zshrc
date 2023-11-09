# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

export LANGUAGE=zh_CN:en_US
export EDITOR=nvim
export ALIYUNPAN_CONFIG_DIR=~/.config/aliyun

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
eval "$(lua /usr/share/z.lua/z.lua --init zsh enhanced once echo)"

# alias
alias s="fastfetch"
alias l="lsd -l"
alias ll="lsd -la"
alias ra="ranger"
alias lg="lazygit"
alias lg="lazygit"
alias gc="git clean -xdf"
alias gl="git log --graph --oneline --decorate --all"
alias b="slstatus -1"

alias hotspot="pkexec create_ap wlan0 lo 'Hiraeth' 'wyz2020zxc'"
alias weather="curl 'v2d.wttr.in/Beijing'"
alias renet="sudo systemctl restart NetworkManager"
alias tran="trans -I -e bing :zh-CN"
alias dict="trans -d -e bing :zh-CN"

alias d="startx"

alias syyu="yay -Syyu"
alias rns="sudo pacman -Rns $(pacman -Qdtq)"
alias scc="yay -Scc"
alias news="yay -Pww"

 # 按两下 Esc 键往上条命令或者当前正在"
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    elif [[ $BUFFER == $EDITOR\ * ]]; then
        LBUFFER="${LBUFFER#$EDITOR }"
        LBUFFER="sudoedit $LBUFFER"
    elif [[ $BUFFER == sudoedit\ * ]]; then
        LBUFFER="${LBUFFER#sudoedit }"
        LBUFFER="$EDITOR $LBUFFER"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line


# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/hiraeth/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
