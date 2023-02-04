#!/bin/bash
set -euxo pipefail

# https://docs.cilium.io/en/v1.12/gettingstarted/kubeproxy-free/#quick-start
helm repo add cilium https://helm.cilium.io/

helm search repo cilium --versions | head

# renovate: datasource=helm registryUrl=https://helm.cilium.io depName=cilium/cilium
CILIUM_HELM_CHART_VERSION=1.12.1

helm upgrade --install cilium cilium/cilium --version $CILIUM_HELM_CHART_VERSION \
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
