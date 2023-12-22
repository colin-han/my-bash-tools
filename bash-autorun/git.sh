local THIS_PATH='/Users/colinhan/online/bash-autorun'
local FEATURE_NAME_FILE=$THIS_PATH/.feature_name

alias ggp='git g && git p'
alias gg='git g'
alias gp='git p'

alias gac="_gac() {
  if [[ \"\$1\" == \"\" ]]; then
    echo \"Commit message is required!\"
    return 1
  fi

  if [[ \"\$1\" == \"-t\" ]]; then
    local TEST=1
    local MSG=\"\$2\"
  else
    local MSG=\"\$1\"
  fi

  if [ -f \"$FEATURE_NAME_FILE\" ]; then
    . \"$FEATURE_NAME_FILE\"
  fi

  if [[ \"\$FEATURE_NAME\" != \"\" ]]; then
    local FMSG=\"[\$FEATURE_NAME] \$MSG\"
  else
    local FMSG=\"\$MSG\"
  fi

  echo -e \"\\033[0;36m git commit -a -m \\\"\$FMSG\\\"\\033[0m\"
  if [[ \"\$TEST\" == \"\" ]]; then
    git commit -a -m \"\$FMSG\"
  fi
}; _gac "

function _gf_echo() {
  echo -e "\033[0;36m" $@ "\033[0m"
}

function _fg_req() {
  if [[ "$1" == "" ]]; then
    echo -e "\033[0;31m Required parameter!\033[0m" >&2
    return 1
  fi
  return 0
}

function _gf_feature_name() {
  if [ -f "$FEATURE_NAME_FILE" ]; then
    . "$FEATURE_NAME_FILE"
  fi
  echo $FEATURE_NAME;
}

function _gf_msg() {
  local MSG=$1
  local FN=$(_gf_feature_name)
  
  if [[ "$FN" != "" ]]; then
    echo "[$FN] $MSG"
  else
    echo "$MSG"
  fi
}

function _gf_set() {
  if [[ "$1" == "" ]]; then
    local FN=$(_gf_feature_name)

    if [[ "$FN" == "" ]]; then
      _gf_echo "current no feature set."
    else
      _gf_echo "current feature is \"[$FN]\""
    fi
  elif [[ "$1" == "-d" ]]; then
    echo "export FEATURE_NAME=" > $FEATURE_NAME_FILE
    _gf_echo "clear feature"
  else
    echo "export FEATURE_NAME=$1" > $FEATURE_NAME_FILE
    _gf_echo "set feature to \"$1\""
  fi
}

function _gf_commit() {
  _gf_echo git commit "$@"
  git commit "$@"
}

function gf() {
  local command="$1"
  shift

  local arg_count=$#
  local last_arg=${@: -1}
  if [[ $arg_count > 1 ]]; then
    local args=("${@:1:(arg_count-1)}")
  fi

  # _gf_echo "last_arg" $last_arg
  # _gf_echo "args" $args

  case $command in 
    'set' | 's')
      _gf_set "$@"
      ;;
    'clear' | 'd')
      _gf_set -d
      ;;
    'commit')
      if [ ${#array[@]} -eq 0 ]; then
        _gf_commit "$(_gf_msg $last_arg)"
      else
        _gf_commit "$args" "$(_gf_msg $last_arg)"
      fi
      ;;
    'c')
      if _fg_req $last_arg; then
        if [ ${#array[@]} -eq 0 ]; then
          _gf_commit -m "$(_gf_msg $last_arg)"
        else
          _gf_commit "$args" -m "$(_gf_msg $last_arg)"
        fi
      fi
      ;;
    'ac')
      if _fg_req $last_arg; then
        if [ ${#array[@]} -eq 0 ]; then
          _gf_commit -a -m "$(_gf_msg $last_arg)"
        else
          _gf_commit "$args" -a -m "$(_gf_msg $last_arg)"
        fi
      fi
      ;;
    'ca')
      if _fg_req $last_arg; then
        if [ ${#array[@]} -eq 0 ]; then
          _gf_commit "--amend" "--no-edit" "-m" "$(_gf_msg $last_arg)"
        else
          _gf_commit "$args" "--amend" "--no-edit" "-m" "$(_gf_msg $last_arg)"
        fi
      fi
      ;;
    esac
}
alias gf='gf'
alias gfs='gf set'
alias gfc='gf c'
alias gfac='gf ac'
alias gfca='gf ca'