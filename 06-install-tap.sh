#!/bin/bash
set -euo pipefail

#
# compute all the dirs and read the settings.sh file
# 
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
readonly WORKSPACE_DIR=${GIT_REPO_ROOT}/workspace
readonly SETTING_SH=${WORKSPACE_DIR}/settings.sh
source ${SETTING_SH}


TAP_VALUES_FILE=${WORKSPACE_DIR}/state/full-tap-values-01.yaml
${GIT_REPO_ROOT}/resources/full/tap-values.sh > ${TAP_VALUES_FILE}

#kubectl apply -f ${GIT_REPO_ROOT}/resources/lb-overlay.yaml
kubectl apply -f ${GIT_REPO_ROOT}/resources/envoy-overlay.yaml

tanzu package install tap \
   -p tap.tanzu.vmware.com \
   -v ${TAP_VERSION} \
   --values-file ${TAP_VALUES_FILE} \
   -n tap-install

#    --ytt-overlay-file ./resources/lb-overlay.yaml \