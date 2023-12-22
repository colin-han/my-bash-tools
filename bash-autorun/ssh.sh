make_ssh_alias() {
    local NAME=$1
    local HOST=$2
    local KEY_FILE=$3
    if [[ $# -ge 4 ]];
    then local PORT=$4;
    else local PORT=22;
    fi

    if [[ $# -ge 5 ]];
    then local USER=$5;
    else local USER=ec2-user;
    fi

    # echo NAME=${NAME} PORT=${PORT} USER=${USER} KEY_FILE=${KEY_FILE}

    alias ${NAME}="ssh -i \"${KEY_FILE}\" -p ${PORT} ${USER}@${HOST}"
    alias c2${NAME}="c2${NAME}() { scp -i \"${KEY_FILE}\" -P ${PORT} \"\$1\" \"${USER}@${HOST}:\$2\"; }; c2${NAME}"
    alias c4${NAME}="c4${NAME}() { scp -i \"${KEY_FILE}\" -P ${PORT} \"${USER}@${HOST}:\$1\" \"\$2\"; }; c4${NAME}"
}

