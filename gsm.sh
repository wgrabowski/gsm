#!/usr/bin/env bash
GSM_DIR=~/.gsm;
GSM_FILE=config;
CONFIG_FILE=$GSM_DIR/$GSM_FILE;
# associative array with paths to ssh keys
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
if [[ -n "${IDS["$1"]}" ]];then
  echo "Identity with name $1 already added. Use different name."
  exit 1;
fi
IDS["$1"]="$2";
update_config
}


list (){
  for key in "${!IDS[@]}"
  do
    echo "${key} ${IDS[${key}]}"
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








