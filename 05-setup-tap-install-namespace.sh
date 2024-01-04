#!/bin/bash
set -euo pipefail

#
# compute all the dirs and read the settings.sh file
# 
readonly SCRIPT_DIR=$(dirname "${0}")
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
readonly WORKSPACE_DIR=${GIT_REPO_ROOT}/workspace
readonly SETTING_SH=${WORKSPACE_DIR}/settings.sh
source ${SETTING_SH}



echo ""
echo "## Creating namespace tap-install"
kubectl apply -f ${SCRIPT_DIR}/resources/tap/namespace.yaml 

readonly TAP_REGISTRY_HOST=registry.tanzu.vmware.com
readonly TAP_REGISTRY_USERNAME=${TANZU_NET_USERNAME}
readonly TAP_REGISTRY_PASSWORD=${TANZU_NET_PASSWORD} 

echo "## Creating tap-registry secret"
tanzu secret registry add tap-registry \
--username "${TAP_REGISTRY_USERNAME}" \
--password "${TAP_REGISTRY_PASSWORD}" \
--server "${TAP_REGISTRY_HOST}" \
--export-to-all-namespaces --yes \
--namespace tap-install

echo "## Adding package repository to tap-install namespace"
tanzu package repository add tanzu-tap-repository \
--url ${TAP_REGISTRY_HOST}/tanzu-application-platform/tap-packages:${TAP_VERSION} \
--namespace tap-install

echo "## Check the status of the added repository"
tanzu package repository get tanzu-tap-repository --namespace tap-install
