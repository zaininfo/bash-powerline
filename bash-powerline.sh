#!/usr/bin/env bash

## Uncomment to disable git info
#POWERLINE_GIT=0

__powerline() {
    if ! hash tput 2>/dev/null; then       
        >&2 echo "tput missing, install ncurses to use bash-powerline.sh"     
        return        
    fi

    # Solarized colorscheme
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
        readonly FG_BASE03="\[$(tput setaf 234)\]"
        readonly FG_BASE02="\[$(tput setaf 235)\]"
        readonly FG_BASE01="\[$(tput setaf 240)\]"
        readonly FG_BASE00="\[$(tput setaf 241)\]"
        readonly FG_BASE0="\[$(tput setaf 244)\]"
        readonly FG_BASE1="\[$(tput setaf 245)\]"
        readonly FG_BASE2="\[$(tput setaf 254)\]"
        readonly FG_BASE3="\[$(tput setaf 230)\]"

        readonly BG_BASE03="\[$(tput setab 234)\]"
        readonly BG_BASE02="\[$(tput setab 235)\]"
        readonly BG_BASE01="\[$(tput setab 240)\]"
        readonly BG_BASE00="\[$(tput setab 241)\]"
        readonly BG_BASE0="\[$(tput setab 244)\]"
        readonly BG_BASE1="\[$(tput setab 245)\]"
        readonly BG_BASE2="\[$(tput setab 254)\]"
        readonly BG_BASE3="\[$(tput setab 230)\]"

        readonly FG_YELLOW="\[$(tput setaf 136)\]"
        readonly FG_ORANGE="\[$(tput setaf 166)\]"
        readonly FG_RED="\[$(tput setaf 160)\]"
        readonly FG_MAGENTA="\[$(tput setaf 125)\]"
        readonly FG_VIOLET="\[$(tput setaf 61)\]"
        readonly FG_BLUE="\[$(tput setaf 33)\]"
        readonly FG_CYAN="\[$(tput setaf 37)\]"
        readonly FG_GREEN="\[$(tput setaf 64)\]"

        readonly BG_YELLOW="\[$(tput setab 136)\]"
        readonly BG_ORANGE="\[$(tput setab 166)\]"
        readonly BG_RED="\[$(tput setab 160)\]"
        readonly BG_MAGENTA="\[$(tput setab 125)\]"
        readonly BG_VIOLET="\[$(tput setab 61)\]"
        readonly BG_BLUE="\[$(tput setab 33)\]"
        readonly BG_CYAN="\[$(tput setab 37)\]"
        readonly BG_GREEN="\[$(tput setab 64)\]"
    else
        readonly FG_BASE03="\[$(tput setaf 8)\]"
        readonly FG_BASE02="\[$(tput setaf 0)\]"
        readonly FG_BASE01="\[$(tput setaf 10)\]"
        readonly FG_BASE00="\[$(tput setaf 11)\]"
        readonly FG_BASE0="\[$(tput setaf 12)\]"
        readonly FG_BASE1="\[$(tput setaf 14)\]"
        readonly FG_BASE2="\[$(tput setaf 7)\]"
        readonly FG_BASE3="\[$(tput setaf 15)\]"

        readonly BG_BASE03="\[$(tput setab 8)\]"
        readonly BG_BASE02="\[$(tput setab 0)\]"
        readonly BG_BASE01="\[$(tput setab 10)\]"
        readonly BG_BASE00="\[$(tput setab 11)\]"
        readonly BG_BASE0="\[$(tput setab 12)\]"
        readonly BG_BASE1="\[$(tput setab 14)\]"
        readonly BG_BASE2="\[$(tput setab 7)\]"
        readonly BG_BASE3="\[$(tput setab 15)\]"

        readonly FG_YELLOW="\[$(tput setaf 3)\]"
        readonly FG_ORANGE="\[$(tput setaf 9)\]"
        readonly FG_RED="\[$(tput setaf 1)\]"
        readonly FG_MAGENTA="\[$(tput setaf 5)\]"
        readonly FG_VIOLET="\[$(tput setaf 13)\]"
        readonly FG_BLUE="\[$(tput setaf 4)\]"
        readonly FG_CYAN="\[$(tput setaf 6)\]"
        readonly FG_GREEN="\[$(tput setaf 2)\]"

        readonly BG_YELLOW="\[$(tput setab 3)\]"
        readonly BG_ORANGE="\[$(tput setab 9)\]"
        readonly BG_RED="\[$(tput setab 1)\]"
        readonly BG_MAGENTA="\[$(tput setab 5)\]"
        readonly BG_VIOLET="\[$(tput setab 13)\]"
        readonly BG_BLUE="\[$(tput setab 4)\]"
        readonly BG_CYAN="\[$(tput setab 6)\]"
        readonly BG_GREEN="\[$(tput setab 2)\]"
    fi

    readonly DIM="\[$(tput dim)\]"
    readonly REVERSE="\[$(tput rev)\]"
    readonly RESET="\[$(tput sgr0)\]"
    readonly BOLD="\[$(tput bold)\]"

    readonly SYMBOL_GIT_BRANCH='⑂ '
    readonly SYMBOL_GIT_MODIFIED='*'
    readonly SYMBOL_GIT_PUSH='↑'
    readonly SYMBOL_GIT_PULL='↓'

    if [[ -z "$PS_SYMBOL" ]]; then
      case "$(uname)" in
          Darwin)   PS_SYMBOL='';;
          Linux)    PS_SYMBOL='$';;
          *)        PS_SYMBOL='%';;
      esac
    fi

    __git_info() { 
        [[ $POWERLINE_GIT = 0 ]] && return # disabled
        hash git 2>/dev/null || return # git not found
        local git_eng="env LANG=C git"   # force git output in English to make our work easier

        # get current branch name
        local ref=$($git_eng symbolic-ref --short HEAD 2>/dev/null)

        if [[ -n "$ref" ]]; then
            # prepend branch symbol
            ref=$SYMBOL_GIT_BRANCH$ref
        else
            # get tag name or short unique hash
            ref=$($git_eng describe --tags --always 2>/dev/null)
        fi

        [[ -n "$ref" ]] || return  # not a git repo

        local marks

        # scan first two lines of output from `git status`
        while IFS= read -r line; do
            if [[ $line =~ ^## ]]; then # header line
                [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PUSH${BASH_REMATCH[1]}"
                [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PULL${BASH_REMATCH[1]}"
            else # branch is modified if output contains more lines after the header line
                marks="$SYMBOL_GIT_MODIFIED$marks"
                break
            fi
        done < <($git_eng status --porcelain --branch 2>/dev/null)  # note the space between the two <

        # print the git branch segment without a trailing newline
        printf " $ref$marks "
    }

    ps1() {
        # Check the exit code of the previous command and display different
        # colors in the prompt accordingly. 
        if [ $? -eq 0 ]; then
            local symbol="$BG_GREEN$FG_BASE3 $PS_SYMBOL $RESET"
        else
            local symbol="$BG_RED$FG_BASE3 $PS_SYMBOL $RESET"
        fi

        local cwd="$BG_BASE1$FG_BASE3 \w $RESET"
        # Bash by default expands the content of PS1 unless promptvars is disabled.
        # We must use another layer of reference to prevent expanding any user
        # provided strings, which would cause security issues.
        # POC: https://github.com/njhartwell/pw3nage
        # Related fix in git-bash: https://github.com/git/git/blob/9d77b0405ce6b471cb5ce3a904368fc25e55643d/contrib/completion/git-prompt.sh#L324
        if shopt -q promptvars; then
            __powerline_git_info="$(__git_info)"
            local git="$BG_BLUE$FG_BASE3\${__powerline_git_info}$RESET"
        else
            # promptvars is disabled. Avoid creating unnecessary env var.
            local git="$BG_BLUE$FG_BASE3$(__git_info)$RESET"
        fi

        PS1="\n$cwd$git$symbol"
    }

    PROMPT_COMMAND="ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
}

__powerline
unset __powerline
