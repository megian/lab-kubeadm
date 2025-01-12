#!/bin/bash
set -euxo pipefail

VERSION="${1:-1.32}"; shift || true

# Installing runtime CRI-O
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o

## Enable IPv4 packet forwarding
## https://kubernetes.io/docs/setup/production-environment/container-runtimes/#prerequisite-ipv4-forwarding-optional

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
br_netfilter
EOF

modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.ipv4.ip_forward                 = 1
net.ipv6.ip_forward                 = 1
EOF
sysctl --system

## Install CRI-O packages
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v$VERSION/deb/ /" | tee /etc/apt/sources.list.d/cri-o.list

curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v$VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

apt-get update
apt-get install -y cri-o
apt-mark hold cri-o

## Start CRI-O
systemctl daemon-reload
systemctl enable crio --now

## Show status
systemctl status cri-o

crio version
crio status info

# show listening ports.
ss -n --tcp --listening --processes
