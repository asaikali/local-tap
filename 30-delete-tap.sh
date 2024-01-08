#!/bin/bash
set -euo pipefail

# read the settings.sh file
readonly GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
source ${GIT_REPO_ROOT}/config/settings.sh

#
# Display a warning message and prompt the user for confirmation
#
readonly WARNING="WARNING: The following items will be deleted:
1. All workload namespaces configured by namespace provisioner apps.tanzu.vmware.com/tap-ns
2. Spring Cloud Gateway package
3. Application Configuration Service package
4. Tanzu Application Platform (tap) package
5. tap-install namespace
6. Secret-gen controller
7. kapp-controller
8. tanzu-cluster-essentials namespace
9. crossplane-system namespace

Are you sure you want to proceed? (y/N): "

echo "${WARNING}"
read -r -p "" RESPONSE

case "$RESPONSE" in
    [yY][eE][sS]|[yY]) 
        # Proceed with deletion
        ;;
    *)
        echo "Delete operation aborted."
        exit 1
        ;;
esac

#
# Delete all the parts of a tap instalation in reverse order from which they created
#

# Delete all workload namespaces configured by namespace provisioner apps.tanzu.vmware.com/tap-ns
kubectl delete namespaces -l apps.tanzu.vmware.com/tap-ns

# Delete Spring Cloud Gateway package
tanzu package installed delete spring-cloud-gateway --namespace tap-install --yes

# Delete Application Configuration Service package
tanzu package installed delete application-configuration-service --namespace tap-install --yes

# Delete Tanzu Application Platform (tap) package
tanzu package installed delete tap --namespace tap-install --yes

# Delete tap-install namespace
kubectl delete namespace tap-install --ignore-not-found

# Delete secret-gen controller
kapp delete -a secretgen-controller -n tanzu-cluster-essentials --yes

# Delete kapp-controller
kapp delete -a kapp-controller -n tanzu-cluster-essentials --yes

# Delete tanzu-cluster-essentials namespace
kubectl delete namespace tanzu-cluster-essentials --ignore-not-found

#
# Crosspalne was installed and tap values has been configured to make
# sure all crossplane objects are deleted, but it seems one object is forgotten
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io  crossplane --ignore-not-found
