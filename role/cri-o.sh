#!/bin/bash
set -euxo pipefail

VERSION="${1:-1.29}"; shift || true

# Installing runtime CRI-O
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o

## Letting iptables see bridged traffic
## https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic

# Create the .conf file to load the modules at bootup
cat <<EOF | tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1

net.bridge.bridge-nf-call-ip6tables = 1
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
