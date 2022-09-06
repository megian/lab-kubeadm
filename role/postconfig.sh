#!/bin/bash
set -euxo pipefail

# Remove control-plane taints
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-
