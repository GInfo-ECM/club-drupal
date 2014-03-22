# We cannot directly use commands like scp or rsync since we cannot directly access
# the server. We use the functions defined below instead. It is advised to put these
# functions in your .bashrc or equivalent in order to use them any time you want. These
# functions are tested and work with bash. They are incompatible witsh zsh.
# They can only take 2 positional parameters.

copy_assos_init() {
    ssh $SSH_ID_SAS "mkdir -p $REMOTE_DIR_TMP_SAS"
}

get_args() {
    if [ "$#" -gt 2 ] ; then
	echo ${@:1:$#-2}
    fi
}

clean() {
    ssh $SSH_ID_SAS "rm -r $REMOTE_DIR_TMP_SAS/*"
}

scp_from_assos() {
    local input=("$@")
    local args=$(get_args $@)
    local source=${input[$#-2]}
    local dest=${input[$#-1]}

    ssh $SSH_ID_SAS "scp $args $SSH_ID_WEBASSOS:$source $REMOTE_DIR_TMP_SAS/$source" &&
    scp $args $SSH_ID_SAS:$REMOTE_DIR_TMP_SAS/$source $dest &&
    clean $source
}

scp_to_assos() {
    local input=("$@")
    local args=$(get_args $@)
    local source=${input[$#-2]}
    local dest=${input[$#-1]}

    scp $args $source $SSH_ID_SAS:$REMOTE_DIR_TMP_SAS/$source &&
    ssh $SSH_ID_SAS "scp $args $REMOTE_DIR_TMP_SAS/$source $SSH_ID_WEBASSOS:$dest" &&
    clean $source
}

rsync_from_assos() {
    local input=("$@")
    local args=$(get_args $@)
    local source=${input[$#-2]}
    local dest=${input[$#-1]}

    ssh $SSH_ID_SAS "mkdir -p $REMOTE_DIR_TMP_SAS/$source"
    ssh $SSH_ID_SAS "rsync $args $SSH_ID_WEBASSOS:$source $REMOTE_DIR_TMP_SAS/$source" &&
    rsync $args $SSH_ID_SAS:$REMOTE_DIR_TMP_SAS/$source $dest &&
    clean $source
}

rsync_to_assos() {
    local input=("$@")
    local args=$(get_args $@)
    local source=${input[$#-2]}
    local dest=${input[$#-1]}

    rsync $args $source $SSH_ID_SAS:$REMOTE_DIR_TMP_SAS/$source &&
    ssh $SSH_ID_SAS "rsync $args $REMOTE_DIR_TMP_SAS/$source $SSH_ID_WEBASSOS:$dest" &&
    clean $source
}
