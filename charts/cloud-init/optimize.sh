#!/bin/bash
set -Eeuo pipefail

trap - SIGINT SIGTERM ERR EXIT
[[ ! -x "$(command -v date)" ]] && echo "💥 date command not found." && exit 1
[[ ! -x "$(command -v bc)" ]] && echo "💥 bc command not found." && exit 1
[[ ! -x "$(command -v mkpasswd)" ]] && echo "💥 gettext-base command not found." && exit 1
[[ ! -x "$(command -v whois)" ]] && echo "💥 whois command not found." && exit 1
[[ ! -x "$(command -v git)" ]] && echo "💥 git command not found." && exit 1
[[ ! -x "$(command -v cloud-init)" ]] && echo "💥 cloud-init command not found." && exit 1
[[ ! -x "$(command -v wget)" ]] && echo "💥 wget command not found." && exit 1
[[ ! -x "$(command -v curl)" ]] && echo "💥 curl command not found." && exit 1

# Generic logging method to return a timestamped string
log() {
    echo >&2 -e "[$(date +"%Y-%m-%d %H:%M:%S")] ${1-}"
}

export ADMIN_PASSWORD="password"
export MAX_PASSWORD="password1"
export USER_DATA_SECRET_PATH="./manifests.yaml"
export USER_DATA_PATH="./user-data.yaml"
export SALT="saltsaltlettuce"
export ENVSUBST=true

# Run envsubst against the user-data file
run_envsubst(){
    if [ "${ENVSUBST}" == "true" ]; then
        log "running envsubst against $USER_DATA_PATH... \n"
        envsubst < "${USER_DATA_PATH}" > tmp.yaml
        mv tmp.yaml "${USER_DATA_PATH}"
    fi
}

# Hash and insert passwd field for each specified user
admin_password(){
    read -ra users <<< $(yq '.users[].name' $USER_DATA_PATH |xargs)
    export COUNT=0

    for user in "${users[@]}"; do
        CHECK=$(yq '.users[env(COUNT)].passwd' $USER_DATA_PATH)
        if [ "${CHECK}" != "null" ]; then
            log "Setting hashed password for user: $user\n"
            CAP_USER=$(echo "${user}" | tr '[:lower:]' '[:upper:]')
            PASSWORD=$(env |grep "${CAP_USER}_PASSWORD" |cut -d '=' -f2)
            export HASHED_PASSWORD=$(mkpasswd --method=SHA-512 --rounds=4096 "${PASSWORD}" -s "${SALT}")
            yq -i '.users[env(COUNT)].passwd = env(HASHED_PASSWORD)' $USER_DATA_PATH
            export COUNT=$(($COUNT + 1))
        fi
    done
}

# Download, gzip, then b64 encode files from specified URLs
download_files(){
    read -ra urls <<< $(yq '.write_files[].url' user-data.yaml |xargs)
    export COUNT=0

    for url in "${urls[@]}"; do
        if [ "${url}" != "null" ]; then
            log "Downloading and compressing file: $(basename $url)"
            export B64GZ_STRING=$(curl -s "${url}" |gzip |base64 -w0)
            yq -i '.write_files[env(COUNT)].content = env(B64GZ_STRING)' $USER_DATA_PATH
            yq -i '.write_files[env(COUNT)].encoding = "gz+b64"' $USER_DATA_PATH
            yq -i 'del(.write_files[env(COUNT)].url)' $USER_DATA_PATH
            check_size
            export COUNT=$(($COUNT + 1))
        fi
    done
}

# Check the size of the user-data file against ec2 16Kb limit
check_size(){
    export SIZE=$(stat -c%s $USER_DATA_PATH)
    export REMAINDER=$((16000 - $SIZE))
    export FULL=$(echo "scale=2; 100-(($REMAINDER/16000)*100)" |bc -l)
    log "user-data file is $SIZE bytes - $FULL% of 16Kb limit.\n"
    if [[ $SIZE -gt 16000 ]]; then
        echo "Warn: user-data file exceeds the 16KB limit"
    fi
}

# Validate user-data is properly formatted
validate(){
    CONFIG_VALID=$(cloud-init schema --config-file $USER_DATA_PATH)
    log "$CONFIG_VALID"
}

log "Starting Cloud-Init Optomizer"
cp $USER_DATA_SECRET_PATH $USER_DATA_PATH
check_size
run_envsubst
admin_password
download_files
validate
log "Done."
