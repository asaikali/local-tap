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

readonly CLUSTER_ESSENTIALS_DIR=${WORKSPACE_DIR}/cluster-essentials

#
# make the state dir
# 
readonly STATE_DIR=${WORKSPACE_DIR}/state
mkdir -p ${STATE_DIR}

#
# Create the namespace 
#
readonly NS_NAME=tanzu-cluster-essentials
echo "## Creating namespace ${NS_NAME}"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NS_NAME}
EOF

#
# Deploy kapp-controller
#
export YTT_registry__server=registry.tanzu.vmware.com
export YTT_registry__username=${TANZU_NET_USERNAME}
export YTT_registry__password=${TANZU_NET_PASSWORD}

echo "## Deploying kapp-controller"

readonly KAPP_CONTROLLER_FILE=${STATE_DIR}/kapp-controller.yaml 
ytt -f ${CLUSTER_ESSENTIALS_DIR}/kapp-controller/config/ \
    -f ${CLUSTER_ESSENTIALS_DIR}/registry-creds/ \
    --data-values-env YTT \
    --data-value-yaml kappController.deployment.concurrency=10 > ${KAPP_CONTROLLER_FILE} 

readonly KAPP_CONTROLLER_RESOLVED_FILE=${STATE_DIR}/kapp-controller-resolved.yaml 
kbld -f ${KAPP_CONTROLLER_FILE} \
     -f ${CLUSTER_ESSENTIALS_DIR}/.imgpkg/images.yml > ${KAPP_CONTROLLER_RESOLVED_FILE}

kapp deploy \
  -a kapp-controller \
  -n ${NS_NAME} \
  -f ${KAPP_CONTROLLER_RESOLVED_FILE} \
  --yes

#
# Deploy secret-gen controller
#

echo "## Deploying secretgen-controller"

readonly SECRETGEN_CONTROLLER_FILE=${STATE_DIR}/secretgen-controller.yaml
ytt -f ${CLUSTER_ESSENTIALS_DIR}/secretgen-controller/config/ \
   -f  ${CLUSTER_ESSENTIALS_DIR}/registry-creds/ \
   --data-values-env YTT > ${SECRETGEN_CONTROLLER_FILE}

readonly SECRETGEN_CONTROLLER_RESOLVED_FILE=${STATE_DIR}/secretgen-controller-resolved.yaml
kbld -f ${SECRETGEN_CONTROLLER_FILE} \
     -f ${CLUSTER_ESSENTIALS_DIR}/.imgpkg/images.yml > ${SECRETGEN_CONTROLLER_RESOLVED_FILE}

kapp deploy \
  -a secretgen-controller \
  -n ${NS_NAME} \
  -f ${SECRETGEN_CONTROLLER_RESOLVED_FILE} \
  --yes


