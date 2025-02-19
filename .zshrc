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

# set up the prompt
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook vcs_info

# Set prompt substitution so we can use the vcs_info_message variable
setopt prompt_subst

# Run the `vcs_info` hook to grab git info before displaying the prompt
add-zsh-hook precmd vcs_info

# Style the vcs_info message
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%b%u%c'
# Format when the repo is in an action (merge, rebase, etc)
zstyle ':vcs_info:git*' actionformats '%F{14}⏱ %*%f'
zstyle ':vcs_info:git*' unstagedstr '*'
zstyle ':vcs_info:git*' stagedstr '+'
# This enables %u and %c (unstaged/staged changes) to work,
# but can be slow on large repos
zstyle ':vcs_info:*:*' check-for-changes true

setopt autonamedirs

# Set the right prompt to the vcs_info message
RPROMPT='%F{yellow}⎇ %F{magenta}($(get_short_branch))%f'

PROMPT='%F{yellow}➜ %F{magenta}%~%f%F{cyan}» %f'
#ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg_bold[red]%}"
#ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
#ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
#----------------------------------------------------------

export HISTSIZE=10000
export HISEFILESIZE=10000
export HISTFILE=/workspace/.zhistory
