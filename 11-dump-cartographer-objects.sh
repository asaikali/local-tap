#!/bin/bash 

#
# This scripts dumps out all the Cartogarpher Custom Resources that are used
# to define supply chains and cluster Tekton objects because they might be 
# used by the runnable tasks in the supply chains
#

set -euo pipefail

#
# helper functions to dump out all instances of a particular type of 
# Kuberentes object as YAML file into a directory structure named after
# the type of object 
#
dump-object() {
  local TYPE=${1}
  local NAME=${2}
  local OUTPUT_DIR=${3}
  
  kubectl get ${TYPE} ${NAME} --ignore-not-found=true -o YAML > ${OUTPUT_DIR}/${NAME}.yaml
}

dump-all-objects() {
  local TYPE=${1} 
  local OUTPUT_DIR=${2}/${TYPE}

  mkdir -p ${OUTPUT_DIR} 

  echo ""
  echo "Dumping objects from cluster"

  for name in $(kubectl get ${TYPE} --ignore-not-found=true --no-headers -o custom-columns=":metadata.name") 
  do 
    echo "Extracting ${TYPE} ${name}"
    dump-object ${TYPE} ${name} ${OUTPUT_DIR} 
  done   
}


#
# Dump objects needed to understand what the supply chain is doing
# 
function dump-cartographer-objects() {
  local DUMP_DIR=workspace/cartographer/
  dump-all-objects ClusterSupplyChain        ${DUMP_DIR}
  dump-all-objects ClusterDelivery           ${DUMP_DIR}
  dump-all-objects ClusterSourceTemplate     ${DUMP_DIR}
  dump-all-objects ClusterImageTemplate      ${DUMP_DIR}
  dump-all-objects ClusterConfigTemplate     ${DUMP_DIR}
  dump-all-objects ClusterDeploymentTemplate ${DUMP_DIR}
  dump-all-objects ClusterTemplate           ${DUMP_DIR}
  dump-all-objects ClusterRunTemplate        ${DUMP_DIR}
  dump-all-objects ClusterTask               ${DUMP_DIR}
}

dump-cartographer-objects 

