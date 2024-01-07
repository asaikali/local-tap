#!/bin/bash
set -euo pipefail

#
# read the install settings
#
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

#
# Check that the registry that we will be pulling TAP images from is accessible
#
docker login ${TANZU_NET_REGISTRY_HOST} \
    --username ${TANZU_NET_USERNAME} \
   --password-stdin <<<"${TANZU_NET_PASSWORD}"

#
# Check that the registry we will be publishing workload container images to is accessible
#
docker login ${WORKLOAD_REGISTRY_HOST} \
    --username ${WORKLOAD_REGISTRY_USERNAME} \
   --password-stdin <<<"${WORKLOAD_REGISTRY_PASSWORD}"
