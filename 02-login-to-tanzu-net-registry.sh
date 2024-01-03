#!/bin/bash
set -euo pipefail

readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
readonly SETTING_SH=${GIT_REPO_ROOT}/workspace/settings.sh
source ${SETTING_SH}

docker login registry.tanzu.vmware.com \
    --username ${TANZU_NET_USERNAME} \
    --password ${TANZU_NET_PASSWORD}



