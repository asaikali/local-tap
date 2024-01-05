#!/bin/bash 

set -eio pipefail

# see https://stackoverflow.com/q/4774054/438319 for how SCRIPT_DIR is computed
readonly SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${SCRIPT_DIR}/../../workspace/settings.sh

readonly TAP_REGISTRY_REPO=${GCP_ARTIFACT_REGISTRY_HOST}/${GCP_PROJECT_ID}/${CODE_NAME}

export TAP_BASE_DOMAIN=${BASE_DOMAIN}
export TAP_INGRESS_DOMAIN="full.${TAP_BASE_DOMAIN}"


export TAP_REGISTRY_REPOSITORY=registry.tanzu.vmware.com/tanzu-application-platform/tap-packages
export TAP_REGISTRY_USERNAME=${TANZU_NET_USERNAME}
export TAP_REGISTRY_PASSWORD=${TANZU_NET_PASSWORD}

# export TAP_METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d)
export TAP_CATALOG_INFO="https://github.com/asaikali/tap-gui-sample-catalog/blob/main/catalog-info.yaml"

export TAP_GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
export TAP_GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}

# determine the root directory of the git repo 
# readonly GIT_REPO_ROOT_DIR=$(git rev-parse --show-toplevel)
# readonly WORKSPACE_DIR=${GIT_REPO_ROOT_DIR}/workspace
# readonly OS_DIR=${WORKSPACE_DIR}/$(uname)
# readonly OS_CLUSTER_ESSENTIALS=${OS_DIR}/tanzu-cluster-essentials
# readonly YTT_BINARY=${OS_CLUSTER_ESSENTIALS}/ytt


ytt -f ${SCRIPT_DIR}/tap-values-template.yaml --data-values-env TAP