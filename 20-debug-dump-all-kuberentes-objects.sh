#!/bin/bash

# Function to get and filter API resources based on namespaced status
get_filtered_api_resources() {
    local is_namespaced=${1}
    shift
    local exclude_types=("$@")

    local namespaced_flag=$([ "${is_namespaced}" = true ] && echo "--namespaced=true" || echo "--namespaced=false")
    local all_resources=$(kubectl api-resources ${namespaced_flag} --verbs=list -o name)
    local filtered_resources=()

    for resource in ${all_resources}; do
        local exclude=false
        for exclude_type in "${exclude_types[@]}"; do
            if [[ "${resource}" == "${exclude_type}" ]]; then
                exclude=true
                break
            fi
        done
        if [[ "${exclude}" = false ]]; then
            filtered_resources+=("${resource}")
        fi
    done

    echo "${filtered_resources[@]}"
}

# Function to list resources in a namespace in wide format
list_namespace_resources() {
    local namespace=${1}
    local namespaced_resources=($(get_filtered_api_resources true "events.events.k8s.io"))


    echo -e "\n\n===================================================================================================="
    echo "Listing objects in Namespace: ${namespace}"
    echo "===================================================================================================="


    for resource in ${namespaced_resources[@]}; do
        local command="kubectl get ${resource} -n ${namespace} -o wide"
        local output=$(${command} 2>/dev/null)
        if [ -n "${output}" ]; then
            echo "Executing: ${command}"
            echo "${output}"
            echo ""
        fi
    done
}

# Function to list cluster-wide resources in wide format
list_cluster_resources() {
    local cluster_resources=($(get_filtered_api_resources false "events.events.k8s.io"))

    echo -e "\n\n===================================================================================================="
    echo "Listing cluster-wide resources (excluding events)"
    echo "===================================================================================================="

    for resource in ${cluster_resources[@]}; do
        local command="kubectl get ${resource} -o wide"
        local output=$(${command} 2>/dev/null)
        if [ -n "${output}" ]; then
            echo "Executing: ${command}"
            echo "${output}"
            echo ""
        fi
    done
}

# Function to get and list resources in all non-system namespaces
list_all_non_system_namespaces_resources() {
    local system_namespaces=("kube-system" "kube-public" "kube-node-lease")
    local namespaces=$(kubectl get ns -o jsonpath="{.items[*].metadata.name}")

    for namespace in ${namespaces}; do
        if [[ ! " ${system_namespaces[@]} " =~ " ${namespace} " ]]; then
            list_namespace_resources "${namespace}"
        fi
    done
}

# List cluster-wide resources
list_cluster_resources

# List resources in all non-system namespaces
list_all_non_system_namespaces_resources
