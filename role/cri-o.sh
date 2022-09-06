#!/bin/bash
set -euxo pipefail

VERSION="${1:-1.24}"; shift || true
OS="${1:-Debian_11}"; shift || true

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
cat <<EOF | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
cat <<EOF | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

curl -sL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/libcontainers.gpg > /dev/null
curl -sL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/libcontainers.gpg > /dev/null

apt-get update
apt-get install -y cri-o cri-o-runc cri-tools
apt-mark hold cri-o cri-o-runc
# https://github.com/kubernetes-sigs/cri-tools

## Start CRI-O
systemctl daemon-reload
systemctl enable crio --now

# install the bash completion scripts.
crictl completion bash >/usr/share/bash-completion/completions/crictl

## Show status
systemctl status cri-o

crio-status --version
crio-status info

crictl version
crictl ps
crictl images

# Cleaning CRI-O storage https://docs.openshift.com/container-platform/4.9/support/troubleshooting/troubleshooting-crio-issues.html#cleaning-crio-storage

# show listening ports.
ss -n --tcp --listening --processes
