#!/bin/bash
set -euo pipefail

# read the settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh


readonly VERSION=$(tanzu package available list spring-cloud-gateway.tanzu.vmware.com --namespace tap-install --column version -o json |  jq -r '.[0].version')

#
# Install Spring Cloud Gateway
#

tanzu package install spring-cloud-gateway \
  --package spring-cloud-gateway.tanzu.vmware.com \
  --version ${VERSION} \
  --namespace tap-install
  