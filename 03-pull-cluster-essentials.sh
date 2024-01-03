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

#
# Pull cluster essentials bundle
# 
readonly LOCK_FILE=${WORKSPACE_DIR}/${CLUSTER_ESSENTIALS_BUNDLE}
readonly CLUSTER_ESSENTIALS_DIR=${WORKSPACE_DIR}/cluster-essentials
imgpkg pull --lock ${LOCK_FILE} -o ${CLUSTER_ESSENTIALS_DIR}
