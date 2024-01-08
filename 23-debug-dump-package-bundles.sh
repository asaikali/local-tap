#!/bin/bash 

#
# This script dumps out all the Package definitions for TAP that are 
# installed in the cluster, each package is put into a folder under 
# cluster director tmp/packages 
#
# This script is useful to better understand how TAP packages are installed
#

set -euo pipefail

#
# read the install settings.sh
#
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

function dump-package() {
  local NAME_SPACE=${1}
  local PACKAGE_NAME=${2}
  local OUTPUT_DIR=${3}/${PACKAGE_NAME}
  local IMAGE_BUNDLE=$( \
    kubectl get package ${PACKAGE_NAME} \
    -n ${NAME_SPACE} \
    -o=jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}'
  )

  mkdir -p ${OUTPUT_DIR}
  imgpkg pull -b ${IMAGE_BUNDLE} -o ${OUTPUT_DIR}
} 

function dump-all-packages() {
  local NAME_SPACE=${1}
  local OUTPUT_DIR=${2}
   
  local PACKAGE_NAMES=$(
    kubectl get package -n ${NAME_SPACE} -o custom-columns=":metadata.name"
  )
  
  for PACKAGE_NAME in ${PACKAGE_NAMES} 
  do 
    dump-package ${NAME_SPACE} ${PACKAGE_NAME} ${OUTPUT_DIR} 
  done 
}

dump-all-packages tap-install ${GIT_REPO_ROOT}/workspace/packages