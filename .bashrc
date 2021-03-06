# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
HISTTIMEFORMAT="%Y%m%d %H:%M:%S "
HISTSIZE=40960
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'
alias ack='ack-grep'
alias awkt='awk -F $"\t"'
alias la='ls -lhA'
alias hls='hadoop fs -ls'
alias hrmr='hadoop fs -rm -r'
alias ep='export PYTHONPATH="."'
#alias r='source /usr/local/bin/ssh-agent-restore'
p()
{
      python /home/wlj/parser.py ${@} | less
}
svndiff()
{
      svn diff "${@}" | colordiff | less -R
}
calc()
{
      echo "${@}" | bc -l
}
s3_peek()
{
    s3_ls ${@} | xargs -n 1 s3_cat | less
}

function r {
 if [[ -n $TMUX ]]; then
   NEW_SSH_AUTH_SOCK=`tmux showenv|grep ^SSH_AUTH_SOCK|cut -d = -f 2`
   if [[ -n $NEW_SSH_AUTH_SOCK ]] && [[ -S $NEW_SSH_AUTH_SOCK ]]; then
     SSH_AUTH_SOCK=$NEW_SSH_AUTH_SOCK
   fi
 fi
}

aless()
{
    avro-read ${@} | less
}
hgrep()
{
    python /home/wlj/code/hadoop-jobs/misc/hadoop_grep.py ${@}
}
s3_ls2()
{
    s3cmd ls s3://analysis.spotify.com${@}
}
#Exports
export PATH=$PATH:/usr/share/spotify-hadoop/bin
export HADOOP_HOME=/usr/lib/hadoop
set completion-ingore-case on
export TMOUT=259200
export LC_CTYPE=en_US.UTF-8
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# Git stuff

function parse_git_deleted {
  [[ $(git status 2> /dev/null | grep deleted:) != "" ]] && echo "${RED}-${RESET}"
}

function parse_git_added {
  [[ $(git status 2> /dev/null | grep "Untracked files:") != "" ]] && echo "${CYAN}+${RESET}"
}

function parse_git_modified {
  [[ $(git status 2> /dev/null | grep modified:) != "" ]] && echo "${YELLOW}*${RESET}"
}

function parse_git_to_be_commited {
  [[ $(git status 2> /dev/null | grep "to be committed:") != "" ]] && echo "${VIOLET}x${RESET}"
}

function parse_git_dirty {
    echo "$(parse_git_added)$(parse_git_modified)$(parse_git_deleted)$(parse_git_to_be_commited)"
}

function parse_git_branch {
  git symbolic-ref HEAD &> /dev/null || return
  echo -n " ("$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* //")$(parse_git_dirty)")"
}

function set_window_title {
  echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: ${PWD/#$HOME/~}\007"
}

fgrep()
{
    NUMFILES=`hadoop fs -ls $1 | grep avro | wc -l`
    FILENUM=`python ~/shard.py $2 $NUMFILES | awk '{print $2}'`
    FILE=`printf "$1/part-%05d.avro" $FILENUM`
    echo Grepping $FILE for $2
    hadoop fs -cat $FILE | avro-read -p | grep $2
}

export EDITOR=emacs

export LS_COLORS="di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=1;30:ow=1;34:st=37;44:ex=01;32:" 

PROMPT_COMMAND='PS1="\u@\h:\w$(parse_git_branch)\$ "; set_window_title'

PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'


function setjdk() {

  if [ $# -ne 0 ]; then

   removeFromPath '/System/Library/Frameworks/JavaVM.framework/Home/bin'

   if [ -n "${JAVA_HOME+x}" ]; then

    removeFromPath $JAVA_HOME/bin

   fi

   export JAVA_HOME=`/usr/libexec/java_home -v $@`

   export PATH=$JAVA_HOME/bin:$PATH

  fi

 }

 function removeFromPath() {

  export PATH=$(echo $PATH | sed -E -e "s;:$1;;" -e "s;$1:?;;")

 }

setjdk 1.8