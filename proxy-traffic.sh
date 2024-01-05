#!/bin/bash

# Specify the Kubernetes service and namespace
SERVICE_NAME="envoy"
NAMESPACE="tanzu-system-ingress"

# Get the NodePort for the HTTP service
HTTP_TARGET=$(kubectl get service -n "$NAMESPACE" "$SERVICE_NAME" -o json | jq -r '.spec.ports[] | select(.name == "http" and .nodePort) | .nodePort')

# Get the NodePort for the HTTPS service
HTTPS_TARGET=$(kubectl get service -n "$NAMESPACE" "$SERVICE_NAME" -o json | jq -r '.spec.ports[] | select(.name == "https" and .nodePort) | .nodePort')

# Print the NodePort targets
echo "HTTP Target NodePort: $HTTP_TARGET"
echo "HTTPS Target NodePort: $HTTPS_TARGET"

# Set up socat forwarding for port 80 to HTTP target
sudo socat TCP-LISTEN:80,fork TCP:localhost:"$HTTP_TARGET" &

# Set up socat forwarding for port 443 to HTTPS target
sudo socat TCP-LISTEN:443,fork TCP:localhost:"$HTTPS_TARGET" &

# Wait for socat processes to finish
echo "use ctrl+c to stop the port mapping" 
wait

