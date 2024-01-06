#!/bin/bash
#
# This script deploys tanzu cluster essentials to a kuberentes cluster
# by using the cluster essentials bundle lock distributed on tanzunet 
# to pull the configuration of cluster essentials and apply to the current
# kuberentes context 
#

set -euo pipefail

# Load the install settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

readonly WORKSPACE_DIR=${GIT_REPO_ROOT}/workspace

# The place to put extract culster essentials packages into
readonly CLUSTER_ESSENTIALS_DIR=${WORKSPACE_DIR}/cluster-essentials

# Clean up existing cluster essentials directory
if [ -d "${CLUSTER_ESSENTIALS_DIR}" ]; then
    echo "Directory ${CLUSTER_ESSENTIALS_DIR} exists. Deleting..."
    rm -rf "${CLUSTER_ESSENTIALS_DIR}"
fi

#
# Pull cluster essentials bundle
#
imgpkg pull --lock config/${CLUSTER_ESSENTIALS_LOCK_FILE} \
            --output ${CLUSTER_ESSENTIALS_DIR}

#
# Create the namespace 
#
readonly NS_NAME=tanzu-cluster-essentials
echo "## Creating namespace ${NS_NAME}"
cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NS_NAME}
EOF

#
# set env vars with the location of the cluster essentials container images
#
export YTT_registry__server=${TANZU_NET_REGISTRY_HOST}
export YTT_registry__username=${TANZU_NET_USERNAME}
export YTT_registry__password=${TANZU_NET_PASSWORD}

#
# deploy kapp-controller
#
echo "## Deploying kapp-controller"
mkdir -p ${WORKSPACE_DIR}/generated
readonly KAPP_CONTROLLER_FILE=${WORKSPACE_DIR}/generated/kapp-controller.yaml 
ytt --file ${CLUSTER_ESSENTIALS_DIR}/kapp-controller/config \
    --file ${CLUSTER_ESSENTIALS_DIR}/registry-creds \
    --data-values-env YTT \
    --data-value-yaml kappController.deployment.concurrency=10 \
    > ${KAPP_CONTROLLER_FILE} 

readonly KAPP_CONTROLLER_RESOLVED_FILE=${WORKSPACE_DIR}/generated/kapp-controller-resolved.yaml 
kbld --file ${KAPP_CONTROLLER_FILE} \
     --file ${CLUSTER_ESSENTIALS_DIR}/.imgpkg/images.yml \
     > ${KAPP_CONTROLLER_RESOLVED_FILE}

kapp deploy --app kapp-controller \
            --namespace ${NS_NAME} \
            --file ${KAPP_CONTROLLER_RESOLVED_FILE} \
            --yes

#
# Deploy secret-gen controller
#
echo "## Deploying secretgen-controller"
readonly SECRETGEN_CONTROLLER_FILE=${WORKSPACE_DIR}/generated/secretgen-controller.yaml
ytt --file ${CLUSTER_ESSENTIALS_DIR}/secretgen-controller/config \
    --file ${CLUSTER_ESSENTIALS_DIR}/registry-creds \
    --data-values-env YTT \
    > ${SECRETGEN_CONTROLLER_FILE}

readonly SECRETGEN_CONTROLLER_RESOLVED_FILE=${WORKSPACE_DIR}/generated/secretgen-controller-resolved.yaml
kbld --file ${SECRETGEN_CONTROLLER_FILE} \
     --file ${CLUSTER_ESSENTIALS_DIR}/.imgpkg/images.yml \
     > ${SECRETGEN_CONTROLLER_RESOLVED_FILE}

kapp deploy --app secretgen-controller \
            --namespace ${NS_NAME} \
            --file ${SECRETGEN_CONTROLLER_RESOLVED_FILE} \
            --yes
