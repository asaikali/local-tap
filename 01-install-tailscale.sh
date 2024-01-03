#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR=$(dirname "${0}")
source ${SCRIPT_DIR}/settings.sh

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