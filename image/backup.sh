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

get_restrictive_id(){
  local fs="${1}"
  local id=""

  id="$( find ${fs} -maxdepth 1 -type f ! -perm -g+r ! -perm -o+r ! -path '*/\.*' -exec stat -c '%u:%g' {} \; | awk 'FNR == 1' )"

  echo "${id}"
}

get_id(){
  local fs="${1}"
  local id=""

  id="$( find ${fs} -maxdepth 1 -type f -exec stat -c '%u:%g' {} \; | awk 'FNR == 1' )"

  echo "${id}"
}

main () {
  local -r src="/source"
  local -r bck_dir="${BCK_FOLDER}"
  local -r dst="/backup"
  local -r user_name="rsyncuser"

  local src_dir="${src}/"

  if ! is_empty "${bck_dir}" && [[ -d "${src}/${bck_dir}" ]] ; then
    src_dir="${src}/${bck_dir}/"
  fi

  dst_dir="${dst}/"

  user_ugid="$( get_restrictive_id ${src_dir} )"
 
  if [[ "${user_ugid}" == "" ]]; then
    user_ugid="$( get_id ${src_dir} )"

    if [[ "${user_ugid}" == "" ]]; then
      echo "The file system/folder ${src_dir} is empty" 
      exit "${E_EMPTYFS}"
    fi

  fi

  user_uid=$(echo $user_ugid | cut -d':' -f1)
  user_gid=$(echo $user_ugid | cut -d':' -f2)

  sed -i "s/${user_name}:x:10002:10002/${user_name}:x:${user_uid}:${user_uid}/g" /etc/passwd
  sed -i "s/${user_name}:x:10002/${user_name}:x:${user_gid}/g" /etc/group

  echo "${USER_PASS}" | su -c "rsync -auvz ${src_dir} ${dst_dir}" "${user_name}"
}

main "$@"

exit "${E_NOERROR}"
