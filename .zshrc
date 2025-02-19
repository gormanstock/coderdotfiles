#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# don't complete remotes for tab complete
__git_commit_tags() {}
__git_heads_remote() {}
zstyle :completion::complete:git-checkout:argument-rest:headrefs command "git for-each-ref --format='%(refname)' refs/heads 2>/dev/null"
zstyle :completion::complete:git-show:argument-rest:headrefs command "git for-each-ref --format='%(refname)' refs/heads 2>/dev/null"

# Customize to your needs...

# non git aliases
alias ga="git add"
alias gr="git restore"
alias gc="git commit -m"
alias gd="git branch -D"
alias deepclean="docker system prune --all"
alias back="cd -"
alias gitcommands="git config --list --show-origin"
alias zsh{config,rc}="gp open ~/.dotfiles/zshrc"
alias c="clear"
alias x="exit"
alias req="python3 -m pip install -r requirements.txt"
alias h="history -10" # last 10 history commands
alias hc="history -c" # clear history
alias hg="history | grep " # +command
alias ag="alias | grep "
alias dotfiles="coder dotfiles https://github.com/gormanstock/coderdotfiles"

# some more ls aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias l.='ls -d .* --color=auto'

alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
alias back='cd -'

function hr {
	print ${(l:COLUMNS::=:)}
}

#----------------------------------------------------------
# COMPLETION SETTINGS
# add custom completion scripts
fpath=(~/.zsh/completion $fpath) 

# compsys initialization
autoload -U compinit
compinit

# show completion menu when number of options is at least 2
zstyle ':completion:*' menu select=2

# load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# format vcs_info variable
zstyle ':vcs_info:git:*' formats ':%F{green}%b%f'

get_short_branch() {
command_output=$(git branch --show-current 2>/dev/null)
output_length=${#command_output}
if [[ "$output_length" -gt 15 ]]; then
  echo "${command_output:0:6}"
else
  echo "$command_output"
fi
}

ZSH_THEME="agnoster"

# set up the prompt
setopt PROMPT_SUBST
#PROMPT='%F{blue}%1~%f${vcs_info_msg_0_} $ '
#PROMPT='%F{magenta}$(get_short_branch)%F{cyan}»%F{magenta}%1~%f%F{cyan}» %f'
PROMPT='%{$fg_bold[cyan]%}%c%{$reset_color%}$(git_prompt_info)%{$fg[green]%}'
PROMPT+="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%}) > %{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg_bold[red]%}"
#ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
#ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
#----------------------------------------------------------

export HISTSIZE=10000
export HISEFILESIZE=10000
export HISTFILE=/workspace/.zhistory
