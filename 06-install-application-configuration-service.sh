#!/bin/bash
set -euo pipefail

# read the settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh


readonly ACS_VERSION=$(tanzu package available list application-configuration-service.tanzu.vmware.com --namespace tap-install --column version -o json |  jq -r '.[0].version')

#
# Install Application Configuration Service
#

se

tanzu package install application-configuration-service \
  --package application-configuration-service.tanzu.vmware.com \
  --version ${ACS_VERSION} \
  --namespace tap-install 
  # --ytt-overlay-file ${GIT_REPO_ROOT}/config/acs-overlay.yaml
  