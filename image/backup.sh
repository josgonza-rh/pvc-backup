#!/bin/bash
# EXIT ERRORS
readonly E_MNTFS=255              # ISSUE MOUNTING FILESYSTEM.
readonly E_EMPTYFS=254            # FILESYSTEM IS EMPTY
readonly E_NOERROR=0              # ALL IT's OK

#FUNCTIONS

is_empty() {
  local var="${1}"
  local empty=1

  if [[ -z "${var}" ]]; then
    empty=0
  fi

  return "${empty}"
}

check_folder() {
  local folder="${1}"
  local exists=0

  if [[ ! -d "${folder}" ]]; then
    exists=1
  fi

  return "${exists}"
}

getid(){
  local fs="${1}"
  local type="${2}"
  local id=""

  if [[ "${type}" == "user" ]]; then
    id="$( find ${fs} -maxdepth 1 -type f ! -perm -g+r ! -perm -o+r ! -path '*/\.*' -exec stat -c '%u' {} \; | awk 'FNR == 1' )"
  else
    id="$( find ${fs} -maxdepth 1 -type f ! -perm -g+r ! -perm -o+r ! -path '*/\.*' -exec stat -c '%g' {} \; | awk 'FNR == 1' )"
  fi

  echo "${id}"
}

main () {
  local -r src="/source"
  local -r bck_dir="${BCK_FOLDER}"
  local -r dst="/backup"
  local -r pvc="${PVC_FOLDER}"
  local -r user_name="rsyncuser"

  local src_dir="${src}/"

  if ! is_empty "${bck_dir}" && check_folder "${src}/${bck_dir}" ; then
    src_dir="${src}/${bck_dir}/"
  fi

  dst_dir="${dst}/${pvc}/"

  user_uid="$( getid ${src_dir} user )"

  if [[ "${user_uid}" == "" ]]; then
    echo "The file system/folder ${src_dir} is empty" 
    exit "${E_EMPTYFS}"
  fi

  user_gid="$( getid ${src_dir} group )"

  sed -i "s/${user_name}:x:10002:10002/${user_name}:x:${user_uid}:${user_uid}/g" /etc/passwd
  sed -i "s/${user_name}:x:10002/${user_name}:x:${user_gid}/g" /etc/group

  echo "${USER_PASS}" | su -c "rsync -auvz ${src_dir} ${dst_dir}" "${user_name}"
}

main "$@"

exit "${E_NOERROR}"