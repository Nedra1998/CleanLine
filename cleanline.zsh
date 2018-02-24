# 
# CleanLine ZSH
#
# Author: Arden Rasmusse
# License: MIT
# https://github.com/Nedra1998/CleanLine-Prompt


# CONFIGURATION {{{
CLEANLINE_PROMPT_ORDER=(user dir pyenv)
if [ -z "$CLEANLINE_PROMPT_ORDER" ]; then
  CLEANLINE_PROMPT_ORDER=(
    time
    user
    dir
    host
    git
    swift
    golang
    pyenv
    exec_time
    jobs
    exit_code
    char
  )
fi
# }}}

# SECTIONS {{{

# Display {{{
section_display() {
  local color prefix content suffix
  [[ -n $1 ]] && color="%F{$1}" || color="%f"
  [[ -n $2 ]] && prefix="$2"    || prefix=""
  [[ -n $3 ]] && content="$3"   || content=""
  [[ -n $4 ]] && suffix="$4"    || suffix=""
  [[ -z $3 && -z $4 ]] && content=$2 prefix=''
  echo -n "%{%B%}" # set bold
  echo -n "$prefix"
  echo -n "%{%B$color%}" # set color
  echo -n "$content"     # section content
  echo -n "%{%b%f%}"     # unset color
  echo -n "%{%B%}" # reset bold, if it was diabled before
  echo -n "$suffix"
  echo -n "%{%b%}" # unset bold
}
# }}}
# Time {{{
CLEANLINE_TIME_12HR=${CLEANLINE_TIME_12HR:-false}
CLEANLINE_TIME_FORMAT=${CLEANLINE_TIME_FORMAT:-false}
cleanline_time() {
  local time_str="%D{%T}"
  [[ $CLEANLINE_TIME_12HR == true ]] && time_str="%D{%r}"
  [[ $CLEANLINE_TIME_FORMAT != false ]] && time_str=$CLEANLINE_TIME_FORMAT
  section_display "" "" "$time_str" ""
}
# }}}
# User {{{
CLEANLINE_USER_SHOW='always'
CLEANLINE_USER_SHOW="${CLEANLINE_USER_SHOW=true}"
CLEANLINE_USER_COLOR="${CLEANLINE_USER_COLOR="black"}"
CLEANLINE_USER_COLOR_ROOT="${CLEANLINE_USER_COLOR_ROOT="yellow"}"
cleanline_user() {
  if [[ $CLEANLINE_USER_SHOW == 'always' ]] \
  || [[ $UID == 0 ]] \
  || [[ $CLEANLINE_USER_SHOW == true && -n $SSH_CONNECTION ]]; then
    local user_color

    if [[ $USER == 'root' ]]; then
      user_color=$CLEANLINE_USER_COLOR_ROOT
    else
      user_color="$CLEANLINE_USER_COLOR"
    fi
    section_display $user_color "" "%n" ""
  fi
}
# }}}
# Pyenv {{{
cleanline_pyenv() {
  local pyenv_status=${$(pyenv version-name 2>/dev/null)//:/ }
  section_display "" "" "$pyenv_status" ""
}
# }}}
# Dir {{{
CLEANLINE_DIR_TRUNC="${CLEANLINE_DIR_TRUNC=3}"
CLEANLINE_DIR_TRUNC_REPO="${CLEANLINE_DIR_TRUNC_REPO=false}"
CLEANLINE_DIR_COLOR="${CLEANLINE_DIR_COLOR="cyan"}"
cleanline_dir() {
  local dir
  if [[ $CLEANLINE_DIR_TRUNC_REPO == true ]]; then
    local git_root=$(git rev-parse --show-toplevel)
    dir="$git_root:t${$(expr $(pwd) : "$git_root\(.*\)")}"
  else
    dir="%${CLEANLINE_DIR_TRUNC}~"
    dir='%~'
  fi
  section_display "$CLEANLINE_DIR_COLOR" "" "$dir" ""
}
# }}}

# }}}

# PROMPT {{{
cleanline_prompt() {
  RETVAL=$?
  for section in $CLEANLINE_PROMPT_ORDER; do
    cleanline_$section
  done
  echo ">>"
}
# }}}

# SETUP {{{
prompt_cleanline_setup() {
  PROMPT="$(cleanline_prompt)"
}
# }}}

# ENTRY POINT {{{
prompt_cleanline_setup "$@"
# }}}
