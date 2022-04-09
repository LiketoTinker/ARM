#!/bin/bash
#
# set up a user and switch to that user

set -euo pipefail

export USER=arm
export HOME="/home/${USER}"

# setup needed/expected dirs if not found
SUBDIRS="config media media/completed media/raw media/movies logs db Music .MakeMKV"
for dir in $SUBDIRS ; do
  thisDir="${HOME}/${dir}"
  if [[ ! -d "${thisDir}" ]] ; then
    echo "creating dir ${thisDir}"
    mkdir -p -m 0777 "${thisDir}"
    chown -R "${USER}.${USER}" "${thisDir}"
  fi
done
if [[ ! -f "${HOME}/config/arm.yaml" ]] ; then
  echo "creating example ARM config ${HOME}/config/arm.yaml"
  cp /opt/arm/docs/arm.yaml.sample "${HOME}/config/arm.yaml"
  chown "${USER}.${USER}" "${HOME}/config/arm.yaml"
fi
if [[ ! -f "${HOME}/config/apprise.yaml" ]] ; then
  echo "creating example apprise config ${HOME}/config/apprise.yaml"
  cp /opt/arm/docs/apprise.yaml "${HOME}/config/apprise.yaml"
  chown "${USER}.${USER}" "${HOME}/config/apprise.yaml"
fi
if [[ ! -f "${HOME}/.abcde.conf" ]] ; then
  echo "creating example abcde config ${HOME}/.abcde.conf"
  cp /opt/arm/setup/.abcde.conf "${HOME}/.abcde.conf"
  ln -sv "${HOME}/.abcde.conf" "${HOME}/config/.abcde.conf"
  chown "${USER}.${USER}" "${HOME}/.abcde.conf"
fi
echo "setting makemkv app-Key"
if ! [[ -z "${MAKEMKV_APP_KEY}" ]] ; then
  echo "app_Key = \"${MAKEMKV_APP_KEY}\"" > "${HOME}/.MakeMKV/settings.conf"
fi

[[ -h /dev/cdrom ]] || ln -sv /dev/sr0 /dev/cdrom 

if [[ "${RUN_AS_USER:-true}" == "true" ]] ; then
  exec /usr/sbin/gosu arm "$@"
else
  exec "$@"
fi
