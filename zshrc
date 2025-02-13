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
#----------------------------------------------------------

export HISTSIZE=10000
export HISEFILESIZE=10000
export HISTFILE=/workspace/.zhistory

export PATH=/ide/bin:$PATH

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change. (From gitpod)
export PATH="$PATH:$HOME/.rvm/bin"

eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
export JAVA_HOME=/home/linuxbrew/.linuxbrew
