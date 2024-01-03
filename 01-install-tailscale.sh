#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR=$(dirname "${0}")
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
readonly SETTING_SH=${GIT_REPO_ROOT}/workspace/settings.sh
source ${SETTING_SH}

helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId=${TAILSCALE_CLIENT_ID} \
  --set-string oauth.clientSecret=${TAILSCALE_CLIENT_SECRET} \
  --set-string operatorConfig.hostname=${TAILSCALE_HOSTNAME} \
  --wait

kubectl get all -n tailscale