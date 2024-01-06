#!/bin/bash
set -euo pipefail

#
# read the install settings
#
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

docker login ${TANZU_NET_REGISTRY_HOST} \
    --username ${TANZU_NET_USERNAME} \
   --password-stdin <<<"${TANZU_NET_PASSWORD}"



