#!/bin/bash 

#
# This scripts dumps out the contents of the tap-packages repositories 
# allowing for the ispection of the Package and PackageMetadata objects
#

set -euo pipefail

#
# read the install settings.sh
#
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

#
# Dump the package repo 
#
imgpkg pull -b \
    ${TANZU_NET_REGISTRY_HOST}/tanzu-application-platform/tap-packages:${TAP_VERSION} \
     -o ${GIT_REPO_ROOT}/workspace/repositories/tap-packages-${TAP_VERSION}