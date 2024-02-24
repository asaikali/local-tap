#!/bin/bash
set -euo pipefail

# read the settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh


# https://docs.vmware.com/en/Application-Service-Adapter-for-VMware-Tanzu-Application-Platform/1.3/tas-adapter/install.html
readonly VERSION=$(tanzu package available list application-service-adapter.tanzu.vmware.com  --namespace tap-install --column version -o json |  jq -r '.[0].version')


set -x
#
# Setup env vars that will be passed to ytt
#
export TAP_WORKLOAD_REPO=${WORKLOAD_REGISTRY_REPO}
export TAP_BASE_DOMAIN=${BASE_DOMAIN}
export TAP_INGRESS_DOMAIN=${TAP_BASE_DOMAIN}

#
# Generate tas-adapter-values.yaml file
#
readonly VALUES_FILE_TEMPLATE=${GIT_REPO_ROOT}/config/tas-adapter-values-template.yaml
readonly VALUES_FILE="${GIT_REPO_ROOT}/workspace/generated/tas-adapter-values.yaml"
ytt -f ${VALUES_FILE_TEMPLATE} --data-values-env TAP > ${VALUES_FILE}

#
# Install the TAS adapter
#

tanzu package install tas-adapter \
  --package application-service-adapter.tanzu.vmware.com  \
  --version ${VERSION} \
  --namespace tap-install \
   --values-file  ${VALUES_FILE}

  