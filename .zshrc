# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache true
local _rc=${ZDOTDIR:-$HOME}/.zshrc

autoload -Uz compinit
compinit
# End of lines added by compinstall
zmodload zsh/stat && alias stat='command stat'
if [[ -f ~/Private/.histfile || ( -d ~/Private && ! -e ~/Private/.histfile && $(zstat -H a ~ && echo ${a[device]}) != $(zstat -H a ~/Private && echo ${a[device]}) ) ]] ; then
	HISTFILE=~/Private/.histfile
else
	HISTFILE=~/.histfile
fi
# Lines configured by zsh-newuser-install
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
bindkey -e
# End of lines configured by zsh-newuser-install

setopt histexpiredupsfirst # If the internal history needs to be trimmed to add the current command
                           # line, setting this option will cause the oldest history event that has
			   # a duplicate to be lost before losing a unique event from the list UNSET
setopt histignoredups      # Do not enter command lines into the history list if they are
                           # duplicates of the previous event UNSET

export EDITOR=vim
export PAGER=less

setopt SHARE_HISTORY
setopt NULL_GLOB           # If a pattern for filename generation has no
                           # matches, delete the pattern from the argument list
                           # instead of reporting an error.
setopt EXTENDED_GLOB       # Allows usage of ^x, x~y, x# and x## patterns
                           # ^x matches everything that doesn't match pattern x
                           # x~y matches everything that matches x but doesn't match y
                           # x# matches everything that matches pattern x zero or more times
                           # x## matches everything that matches pattern x once or more times

if [[ "`uname -o`" = "FreeBSD" && $TERM = screen-256color-s ]]; then
	# Apparently screen-256color-s doesn't work very well on FreeBSD
	export TERM=screen-256color
fi

typeset -A term_colors

if [[ ${terminfo[colors]} == 256 ]]; then () {
    # Solarize the prompt

    local -A solarized_colors

    solarized_colors[yellow]="b5/89/00"
    solarized_colors[orange]="cb/4b/16"
    solarized_colors[red]="dc/32/2f"
    solarized_colors[magenta]="d3/36/82"
    solarized_colors[violet]="6c/71/c4"
    solarized_colors[blue]="26/8b/d2"
    solarized_colors[cyan]="2a/a1/98"
    solarized_colors[green]="85/99/00"

    # XTerm 256 colors closest to the ones we need: the change should be minimal
    term_colors[red]=160
    term_colors[green]=64
    term_colors[yellow]=136
    term_colors[blue]=33
    term_colors[magenta]=125
    term_colors[cyan]=37
    term_colors[orange]=166
    term_colors[violet]=61

    # Dark

    solarized_colors[base03]="00/2b/36"
    solarized_colors[base02]="07/36/42"
    solarized_colors[base01]="58/6e/75"
    solarized_colors[base00]="65/7b/83"
    solarized_colors[base0]="83/94/96"
    solarized_colors[base1]="93/a1/a1"
    solarized_colors[base2]="ee/e8/d5"
    solarized_colors[base3]="fd/f6/e3"

    # XTerm 256 colors closest to the ones we need: the change should be minimal
    term_colors[base03]=234
    term_colors[base02]=235
    term_colors[base01]=240
    term_colors[base00]=241
    term_colors[base0]=244
    term_colors[base1]=245
    term_colors[base2]=254
    term_colors[base3]=230

    term_colors[bg]="${term_colors[base03]}"
    term_colors[fg]="${term_colors[base0]}"

    if [[ $TERM == xterm* ]]; then
        # Make the 256-color space match the colors we need exactly
        local color ctlseq=$'\e]4'
        for color in ${(k)term_colors}
        do
            if [[ -n ${solarized_colors[$color]} ]]; then
                ctlseq="${ctlseq};${term_colors[$color]};rgb:${solarized_colors[$color]}"
            fi
        done
        ctlseq="${ctlseq}"$'\a'
        echo -n "${ctlseq}"
    fi
}; fi

: ${term_colors[black]:=black}
: ${term_colors[green]:=green}
: ${term_colors[yellow]:=yellow}
: ${term_colors[red]:=red}
: ${term_colors[magenta]:=magenta}
: ${term_colors[blue]:=blue}
: ${term_colors[cyan]:=cyan}
: ${term_colors[white]:=white}
: ${term_colors[bg]:=default}
: ${term_colors[fg]:=default}

PS1="%F{${term_colors[fg]}}[%B%(?.%F{${term_colors[yellow]}}.%F{${term_colors[red]}})%?%b%F{${term_colors[fg]}}:%B%F{${term_colors[blue]}}%n%F{${term_colors[fg]}}@%F{${term_colors[green]}}%U%m%u%b%F{${term_colors[fg]}}:%B%F{${term_colors[red]}}%2~%b%F{${term_colors[fg]}}]%(!.#.\$)%f "
RPS1="%F{${term_colors[yellow]}}(%D{%Y-%m-%d %H:%M:%S})%f"

function precmd() {
	# Print info to window title (if the terminal supports it)
	local _term_title="${_term_title:-%n@%m: %~}"
	if (( $+termcap[ts] && $+termcap[fs] )); then
		print -Pn "$termcap[ts]${_term_title}$termcap[fs]"
	elif (( $+terminfo[tsl] && $+terminfo[fsl] )); then
		print -Pn "$terminfo[tsl]${_term_title}$terminfo[fsl]"
	elif [[ $TERM == (dtterm|screen|xrvt|xterm)* ]]; then
		print -Pn "\e]0;${_term_title}\a"
	fi
}

if [[ -f ~/.projectrc ]]; then
    source ~/.projectrc
fi

# enable color support of ls and also add handy aliases
function _enable_dircolors() {
    local _DIR_COLOR_F

    if [[ -f ~/.dir_colors ]]; then
        _DIR_COLOR_F=~/.dir_colors
    fi
    eval "`$1 -b ${_DIR_COLOR_F}`"
    if [[ -z $LS_COLORS && $TERM = screen-256color-s ]]; then
        eval "`TERM=screen-256color $1 -b ${_DIR_COLOR_F}`"
    fi
}

if [[ -x /usr/bin/dircolors ]]; then
    _enable_dircolors /usr/bin/dircolors
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
elif [[ "`uname -s`" = "SunOS" ]]; then
    alias ls='ls -F'
else
    export CLICOLOR=yes
    export LSCOLORS=ExGxFxdxCxDxDxhbadacec
    alias grep='grep --colour=auto'
fi
if (( ! ${+LS_COLORS} && ${+commands[gdircolors]} && ${+commands[gls]} )); then
    _enable_dircolors gdircolors
    alias ls='gls --color=auto'
fi

if zmodload zsh/complist 2> /dev/null
then
	if [[ -n $LS_COLORS ]]
	then
		zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
	else
		zstyle ':completion:*:default' list-colors ''
	fi
fi

# some more ls aliases
alias ll='ls -Al'
alias la='ls -A'
alias lt='ls -tr'
#alias l='ls -CF'

# Got this piece of code from bkhl. Thanks. :-)
if [[ -f ~/.ssh/known_hosts ]]; then
function {
	_etchosts=(${${(s: :)${(ps:\t:)${${(f)"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}:#(localhost|ip6-*|127.[0-9].[0-9].[0-9]|f[ef]0[02]::[0-2]|::1)})
	_sshhosts=(${${${${(f)"$(<~/.ssh/known_hosts)"}:#[0-9\[]*}%%\ *}%%,*})
	_myhosts=($_etchosts $_sshhosts)

	zstyle ':completion:*' hosts $_myhosts
}
fi

if [[ -f ~/.ssh/users ]]; then
	_myusers=(${${(f)"$(<~/.ssh/users)"}%%\#*})
	zstyle ':completion:*' users $_myusers
fi

source ${_rc:A:h}/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ${_rc:A:h}/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Replace syntax highlighting colors with solarized versions (if we're using solarized)
function {
	local class style colname color re_repl_colors

	# Find the colors that need to be replaced
	local -a replace_colors
	for colname in ${(k)term_colors}
	do
		if [[ $colname != [fb]g && ${term_colors[$colname]} != $colname ]]; then
			replace_colors+=$colname
		fi
	done
	re_repl_colors="${replace_colors:+(${(j.|.)replace_colors})}"

	# Replace them in the syntax highlighting styles
	for class in ${(k)ZSH_HIGHLIGHT_STYLES}
	do
		style=${ZSH_HIGHLIGHT_STYLES[$class]}
		while [[ $style =~ "[fb]g=${re_repl_colors}(,|\$)" ]]; do
			style="${style[0,${mbegin[1]}-1]}${term_colors[${match[1]}]}${style[${mend[1]}+1,-1]}"
		done
		ZSH_HIGHLIGHT_STYLES[${class}]="${style}"
	done
}

if (( $+termcap[ho] )); then
	bindkey $termcap[ho] beginning-of-line
elif (( $+terminfo[home] )); then
	bindkey $terminfo[home] beginning-of-line
fi
if (( $+termcap[kh] )); then
	bindkey $termcap[kh] beginning-of-line
elif (( $+terminfo[khome] )); then
	bindkey $terminfo[khome] beginning-of-line
fi
bindkey "\e[1~" beginning-of-line       # home, xterm binding

if (( $+termcap[@7] )); then
	bindkey $termcap[@7] end-of-line
elif (( $+terminfo[kend] )); then
	bindkey $terminfo[kend] end-of-line
fi
bindkey "\e[4~" end-of-line             # end, xterm binding

if (( $+termcap[kP] )); then
	bindkey $termcap[kP] history-search-backward
elif (( $+terminfo[kpp] )); then
	bindkey $terminfo[kpp] history-search-backward
else
	bindkey "\e[5~" history-search-backward # page-up fallback
fi
if (( $+termcap[kN] )); then
	bindkey $termcap[kN] history-search-forward
elif (( $+terminfo[knp] )); then
	bindkey $terminfo[knp] history-search-forward
else
	bindkey "\e[6~" history-search-forward  # page-down fallback
fi
if (( $+termcap[kD] )); then
	bindkey $termcap[kD] delete-char
elif (( $+terminfo[kdch1] )); then
	bindkey $terminfo[kdch1] delete-char
else
	bindkey "\e[3~" delete-char             # delete fallback
fi
if (( $+termcap[kI] )); then
	bindkey $termcap[kI] quoted-insert
elif (( $+terminfo[kdch1] )); then
	bindkey $terminfo[kich1] quoted-insert
else
	bindkey "\e[2~" quoted-insert           # insert fallback
fi
if (( $+termcap[ku] )); then
	bindkey $termcap[ku] history-substring-search-up
elif (( $+terminfo[kcuu1] )); then
	bindkey $terminfo[kcuu1] history-substring-search-up
fi
if (( $+termcap[kd] )); then
	bindkey $termcap[kd] history-substring-search-down
elif (( $+terminfo[kcud1] )); then
	bindkey $terminfo[kcud1] history-substring-search-down
fi
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M vicmd  'k' history-substring-search-up
bindkey -M vicmd  'j' history-substring-search-down
bindkey '^[[A'        history-substring-search-up
bindkey '^[[B'        history-substring-search-down

# mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving
bindkey "\e[1;5C" forward-word          # VT220 control-right
bindkey "\e[1;5D" backward-word         # VT220 control-left
bindkey "\e[5C" forward-word            # PuTTY or Screen control-right
bindkey "\e[5D" backward-word           # PuTTY or Screen control-left
#bindkey "\eOC" forward-word            # PuTTY or Screen control-right
#bindkey "\eOD" backward-word           # PuTTY or Screen control-left
bindkey "\e\e[C" forward-word           # PuTTY or Screen control-right
bindkey "\e\e[D" backward-word          # PuTTY or Screen control-left

bindkey "\e[8~" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line

autoload insert-composed-char
zle -N insert-composed-char
bindkey "^K" insert-composed-char

svndiff() {
	svn diff "$@" | pygmentize -ldiff | less -R
}

svn-clean() {
	svn status --no-ignore "$@" | awk '/^[\?I]/ { sub(/^[?I] +/, ""); print }' | xargs --delimiter='\n' rm -r
}

if type tor > /dev/null 2>&1 || [[ -x /sbin/tor || -x /usr/sbin/tor || -x /usr/local/sbin/tor ]]
then
	tor-new-exitnode() {
		echo -e 'authenticate "'"$(< /var/run/tor/control.authcookie)"'"\nsignal newnym' | { nc -U /var/run/tor/control || nc 127.0.0.1 9051 } > /dev/null || {
			rc=$?
			echo 'error: failed to connect to 127.0.0.1:9501' >&2
			return $rc
		}
	}
fi

if (( ${+commands[host]} && ${+commands[ipv6calc]} && ${+commands[wakeonlan]} ))
then
	wake() {
		local host address mac_eui48
		for host in "$@"; do
			address=`host -t aaaa "$host" 2> /dev/null | cut -f 5 -d ' '`
			mac_eui48=`ipv6calc --in ipv6addr --showinfo --machine_readable "$address" 2> /dev/null | grep '^EUI48=' | sed 's/^EUI48=//'`
			wakeonlan "$mac_eui48"
		done
	}

	# Completion rule to ensure hostnames are used as parameters
	compdef '_arguments "*:hosts:_hosts"' wake
fi

if (( ${+commands[snmpget]} ))
then
	snmpuptime() {
		local host
		for host in "$@"; do
			echo -n "$host: "
			snmpget -c public -v 1 "$host" 1.3.6.1.2.1.25.1.1.0 | sed 's/^.*) *//'
		done
	}

	# Completion rule to ensure hostnames are used as parameters
	compdef '_arguments "*:hosts:_hosts"' snmpuptime
fi

# Execute a command after the given set of processes have finished
do-after() {
	if [[ "$#" -lt 2 ]]
	then
		echo "Usage: $0 command_string pid ..." >&2
		return 64
	fi

	local cmd="$1"
	shift

	echo "set -e"
	echo

	for pid in "$@"
	do
		cat <<EOF
while kill -0 $pid > /dev/null 2>&1
do
	sleep 30
done
EOF
	done

	echo
	echo "$cmd"
}
compdef '_arguments ":command:_command" "*:processes:_pids"' do-after

if   (( ${+commands[zfs]} )) ; then
	true
elif [[ -x "/sbin/zfs" ]] ; then
	ZFS="/sbin/zfs"
elif [[ -x "/usr/sbin/zfs" ]] ; then
	ZFS="/usr/sbin/zfs"
elif [[ -x "/usr/local/sbin/zfs" ]] ; then
	ZFS="/usr/local/sbin/zfs"
fi

if [[ -n "$ZFS" ]] ; then
	eval "zfs() {
		sudo ${(q)ZFS} \"\$@\"
	}"
	unset ZFS
fi

if   (( ${+commands[zpool]} )) ; then
	true
elif [[ -x "/sbin/zpool" ]] ; then
	ZPOOL="/sbin/zpool"
elif [[ -x "/usr/sbin/zpool" ]] ; then
	ZPOOL="/usr/sbin/zpool"
elif [[ -x "/usr/local/sbin/zpool" ]] ; then
	ZPOOL="/usr/local/sbin/zpool"
fi

if [[ -n "$ZPOOL" ]] ; then
	eval "zpool() {
		sudo ${(q)ZPOOL} \"\$@\"
	}"
	unset ZPOOL
fi

source ~/.zprofile

# Load C-shell style aliases
if [[ -f ~/.aliases && -r ~/.aliases && -s ~/.aliases ]]; then
	function alias() {
		if [[ $# -lt 1 ]]; then
			builtin alias
			return
		fi
		local name="$1"
		shift
		builtin alias "$name"="$@"
	}
	. ~/.aliases
	unfunction alias
fi

# optional autojump support, if installed
if (( ${+commands[autojump]} )); then
() {
    local fname
    local -a fnames
    fnames+=$HOME/.autojump/etc/profile.d/autojump.zsh  # user-specific config
    fnames+=/usr/share/autojump/autojump.zsh            # Debian package
    fnames+=/etc/profile.d/autojump.zsh                 # manual install
    fnames+=/etc/profile.d/autojump.sh                  # Gentoo port
    fnames+=/usr/local/share/autojump/autojump.zsh      # FreeBSD port
    fnames+=/opt/local/etc/profile.d/autojump.zsh       # OSX port
    if (( ${+commands[brew]} )); then
        fnames+=`brew --prefix`/etc/autojump.zsh        # OSX brew
    fi
    for fname in $fnames; do
        if [[ -f $fname ]]; then
            source $fname
            break
        fi
    done
}
fi
