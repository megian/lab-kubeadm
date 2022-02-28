#!/bin/bash
set -euxo pipefail

# https://docs.cilium.io/en/v1.11/gettingstarted/kubeproxy-free/#quick-start
helm repo add cilium https://helm.cilium.io/

helm search repo cilium --versions | head

helm install cilium cilium/cilium --version 1.11.1 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=vip.$(hostname -d) \
    --set k8sServicePort=6443 \
    --set ipam=kubernetes \
    --set tunnel=disabled \
    --set enable-endpoint-routes=true \
    --set enable-local-node-route=false

#    --set native-routing-cidr=10.0.0.0/16 \

# cilium status --wait
