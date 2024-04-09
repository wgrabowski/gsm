#!/usr/bin/env bash
GSM_DIR=~/.gsm;
CONFIG_FILE=$GSM_DIR/config;
# associative array with paths to ssh keys
# actual values read and saved to $CONFIG_FILE
declare -A IDS;

read_config (){
  source $CONFIG_FILE;
}

init(){
  # create settings file if doesn't exists
if [ ! -f $CONFIG_FILE ]; then
  mkdir -p $GSM_DIR;
  touch $CONFIG_FILE;
fi

read_config

}

update_config (){
# Overwrite config file with values
echo "IDS=(" | cat > $CONFIG_FILE
for key in "${!IDS[@]}"
do
  echo "[${key}]=\"${IDS[${key}]}\"" | cat >> $CONFIG_FILE
done
echo ")" | cat >> $CONFIG_FILE
echo "Updated."
read_config
}

# $1 - name
# $2 - ssh key file path
add(){
  if [[ ! -f $2 ]];then
  echo "File $2 doesn't exist."
    exit 1;
  fi

  if [[ -n "${IDS["$1"]}" ]];then
    echo "Identity with name $1 already added. Use different name."
    exit 1;
  fi
  IDS["$1"]="$2";
  update_config
}

reset(){
  git config --global --unset core.sshCommand
}

list (){
  currentKey=`git config --global  --get core.sshCommand |  rev | cut -d" " -f 1 | rev`;

  for key in "${!IDS[@]}"
  do
    val=${IDS[${key}]};
    if [[ $currentKey == $val ]];then
    echo "* ${key} ${val}"
    else
      echo "${key} ${val}"
    fi
  done
}

# $1 - name of entry to be used
use(){
  if [[ -n "${IDS["$1"]}" ]];then
  git config --global core.sshCommand "ssh -i ${IDS[$1]}";
  else
    echo "Identity $1 is not added"
    echo "Use gsm list to see all added identities"
  fi
}

# $1 - identity key
remove (){
  currentKey=`git config --global  --get core.sshCommand |  rev | cut -d" " -f 1 | rev`;
  if [[ $currentKey == ${IDS[$1]} ]];then
    reset
  fi
unset 'IDS[$1]'
update_config
}


usage() {
  echo "gsm - git ssh identity manager"
  echo "gsm list"
  echo "gsm use <name>"
  echo "gsm add <name> <private-key-path>"
  echo "gsm remove <name> <private-key-path>"
  exit 1;
}

init

[ $# -eq 0 ] && usage

while [[ $# -gt 0 ]] ; do
  case "$1" in
    list)
      list
      ;;
    add)
      add "$2" "$3"
      shift
      shift
      ;;
    use)
      use "$2"
      shift
      ;;
    remove)
      remove "$2"
      shift
      ;;
    *)
      usage
      ;;
  esac
  shift
done








