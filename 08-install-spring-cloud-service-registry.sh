#!/bin/bash
set -euo pipefail

# read the settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh


# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/service-registry-install-service-registry.html
readonly ACS_VERSION=$(tanzu package available list service-registry.spring.apps.tanzu.vmware.com  --namespace tap-install --column version -o json |  jq -r '.[0].version')

#
# Install Spring Cloud Service Registry
#

tanzu package install service-registry \
  --package service-registry.spring.apps.tanzu.vmware.com  \
  --version ${ACS_VERSION} \
  --namespace tap-install \

  