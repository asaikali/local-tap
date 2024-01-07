#!/bin/bash

# Check if required CLIs are installed
required_clis=("imgpkg" "ytt" "kbld" "kapp" "kubectl" "jq" "socat")
missing_clis=()

echo "Checking for required CLIs..."

for cli in "${required_clis[@]}"; do
    if command -v "$cli" &> /dev/null; then
        echo "$cli found."
    else
        missing_clis+=("$cli")
    fi
done

if [ ${#missing_clis[@]} -ne 0 ]; then
    echo "The following required CLIs are missing:"
    for cli in "${missing_clis[@]}"; do
        echo "- $cli"
    done
    echo "Please install the missing CLIs before running the script."
    exit 1
fi

echo "All required CLIs are available."
