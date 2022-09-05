#!/bin/bash
set -euxo pipefail

function step (echo -e "\033[0;34m== ${1} ==\033[0m")

step "list runnnig pods"
crictl pods

step "list running containers"
crictl ps

# Remove control-plane taints
# kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# kubectl taint nodes --all node-role.kubernetes.io/master-
