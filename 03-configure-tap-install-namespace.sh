#!/bin/bash
set -euo pipefail

# read the settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

echo ""
echo "## Creating namespace tap-install"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: tap-install
EOF

echo "## Creating tap-registry secret"
tanzu secret registry add tap-registry \
    --server   "${TANZU_NET_REGISTRY_HOST}" \
    --username "${TANZU_NET_USERNAME}" \
    --password "${TANZU_NET_PASSWORD}" \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes

echo "## Creating workload-registry secret"
tanzu secret registry add workload-registry \
    --server   "${WORKLOAD_REGISTRY_HOST}" \
    --username "${WORKLOAD_REGISTRY_USERNAME}" \
    --password "${WORKLOAD_REGISTRY_PASSWORD}" \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes

echo "## Adding TAP package repository to tap-install namespace"
tanzu package repository add tanzu-tap-repository \
    --url "${TANZU_NET_REGISTRY_HOST}/tanzu-application-platform/tap-packages:${TAP_VERSION}" \
    --namespace tap-install

echo "## Check the status of the added repository"
tanzu package repository get tanzu-tap-repository --namespace tap-install

echo "## Adding TAS Adapter package repository to tap-install namespace"
tanzu package repository add tas-adapter-repository \
  --url "${TANZU_NET_REGISTRY_HOST}/app-service-adapter/tas-adapter-package-repo:${TAS_ADAPTER_VERSION}" \
  --namespace tap-install

echo "## Check the status of the added repository"
tanzu package repository get tas-adapter-repository --namespace tap-install