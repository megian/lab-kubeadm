#!/bin/bash
set -euxo pipefail

# https://docs.cilium.io/en/v1.11/gettingstarted/kubeproxy-free/#quick-start
helm repo add cilium https://helm.cilium.io/

helm search repo cilium --versions | head

helm upgrade --install cilium cilium/cilium --version 1.12.1 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=vip.$(hostname -d) \
    --set k8sServicePort=6443

# Enable native routing
#
#    --set ipam.mode=kubernetes \
#    --set tunnel=disabled \
#    --set enable-endpoint-routes=true \
#    --set enable-local-node-route=false
#    --set native-routing-cidr=10.0.0.0/16 \
#
# Requires --allocate-node-cidrs on the kubernetes controller

# cilium status --wait

# cilium connectivity test
