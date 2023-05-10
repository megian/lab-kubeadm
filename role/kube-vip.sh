#!/bin/bash
set -euxo pipefail

# Get latest kube-vip tag
IMAGE_TAG_LATEST=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")

VIP="$1"; shift
INTERFACE="${1:-}"; shift || true
IMAGE_TAG="${1:-$IMAGE_TAG_LATEST}"; shift || true

# https://kube-vip.io/docs/installation/static/

# Prefetch image
# crictl pull ghcr.io/kube-vip/kube-vip:$IMAGE_TAG

# Create kubernetes manifests directory
mkdir -p /etc/kubernetes/manifests/

# https://kube-vip.io/docs/installation/static/#arp
#
# crictl run ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip \
#     manifest pod \
#     --interface "$INTERFACE" \
#     --address "$VIP" \
#     --controlplane \
#     --services \
#     --arp \
#     --leaderElection | tee /etc/kubernetes/manifests/kube-vip.yaml

cat >/etc/kubernetes/manifests/kube-vip.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: kube-vip
  namespace: kube-system
spec:
  containers:
  - args:
    - manager
    env:
    - name: vip_arp
      value: "true"
    - name: port
      value: "6443"
    - name: vip_interface
      value: ${INTERFACE}
    - name: vip_cidr
      value: "32"
    - name: cp_enable
      value: "true"
    - name: cp_namespace
      value: kube-system
    - name: vip_ddns
      value: "false"
    - name: svc_enable
      value: "true"
    - name: vip_leaderelection
      value: "true"
    - name: vip_leaseduration
      value: "5"
    - name: vip_renewdeadline
      value: "3"
    - name: vip_retryperiod
      value: "1"
    - name: address
      value: ${VIP}
    image: ghcr.io/kube-vip/kube-vip:${IMAGE_TAG}
    imagePullPolicy: Always
    name: kube-vip
    resources: {}
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        - NET_RAW
        - SYS_TIME
    volumeMounts:
    - mountPath: /etc/kubernetes/admin.conf
      name: kubeconfig
  hostAliases:
  - hostnames:
    - kubernetes
    ip: 127.0.0.1
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/admin.conf
    name: kubeconfig
EOF
