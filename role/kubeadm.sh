#!/bin/bash
set -euxo pipefail

kubeadm_command="${1:-cluster-init}"; shift || true

function step (
    # Black        0;30     Dark Gray     1;30
    # Red          0;31     Light Red     1;31
    # Green        0;32     Light Green   1;32
    # Brown/Orange 0;33     Yellow        1;33
    # Blue         0;34     Light Blue    1;34
    # Purple       0;35     Light Purple  1;35
    # Cyan         0;36     Light Cyan    1;36
    # Light Gray   0;37     White         1;37

    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    echo -e "${BLUE}== ${1} ==${NC}"
)

step "Download the Google Cloud public signing key"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

step "Add the Kubernetes apt repository"
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

step "Update apt package index, install kubelet, kubeadm and kubectl, and pin their version"
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

kubectl completion bash >/usr/share/bash-completion/completions/kubectl

cat > /etc/profile.d/01-kubectl-alias.sh <<'EOF'
alias k=kubectl
EOF
source /etc/profile.d/01-kubectl-alias.sh

cat >/etc/profile.d/01-kubectl-kubeconfig.sh <<'EOF'
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF
source /etc/profile.d/01-kubectl-kubeconfig.sh

step "Prefetch kubeadm images"
# We do not need kube-proxy because cilium will take over this part
time kubeadm config images list | grep -v kube-proxy | xargs -L1 crictl pull

if [ "$kubeadm_command" == 'cluster-init' ]; then
  step "Cluster Init"

  # https://docs.cilium.io/en/v1.11/gettingstarted/k8s-install-kubeadm/#create-the-cluster
  # https://docs.cilium.io/en/v1.11/gettingstarted/kubeproxy-free/#kubeproxy-free
  kubeadm init --control-plane-endpoint vip.$(hostname --domain) --pod-network-cidr 10.12.0.0/16 --service-cidr 10.13.0.0/16 --skip-phases=addon/kube-proxy

  # TODO: Check --upload-certs
  # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#uploading-control-plane-certificates-to-the-cluster

  # cluster-cidr: 10.12.0.0/16
  # service-cidr: 10.13.0.0/16  # default: 10.96.0.0/12
  # cluster-dns: 10.13.0.10  # default: 10.96.0.10
  # cluster-domain: cluster.local

  mkdir -p /vagrant/tmp
  join=$(kubeadm token create --print-join-command)

  # Unsecure control-plane token
  echo "$join --control-plane" > /vagrant/tmp/join-controlplane
  echo /vagrant/tmp/join-controlplane

  # Unsecure worker token
  echo $join > /vagrant/tmp/join-worker
  echo /vagrant/tmp/join-worker

  # TODO: don't get ready because cilium isn't there yet
  # wait for this node to be Ready.
  # e.g. n1     Ready    control-plane,master   3m54s   v1.23.2
  #$SHELL -c 'node_name=$(hostname); echo "waiting for node $node_name to be ready..."; while [ -z "$(kubectl get nodes $node_name | grep -E "$node_name\s+Ready\s+")" ]; do sleep 3; done; echo "node ready!"'

  step "Show etcd CA certificate"
  openssl x509 -noout -in /etc/kubernetes/pki/etcd/ca.crt -issuer -subject -dates
  step "Show kubernetes CA certificate"
  openssl x509 -noout -in /etc/kubernetes/pki/ca.crt -issuer -subject -dates
  step "Show front-proxy-ca certificate"
  openssl x509 -noout -in /etc/kubernetes/pki/front-proxy-ca.crt -issuer -subject -dates

  # Copy certificates and service account key
  mkdir -p /vagrant/tmp/pki/etcd
  cp /etc/kubernetes/pki/{ca,front-proxy-ca}.{key,crt} /vagrant/tmp/pki
  cp /etc/kubernetes/pki/sa.{key,pub} /vagrant/tmp/pki
  cp /etc/kubernetes/pki/etcd/ca.{key,crt} /vagrant/tmp/pki/etcd
fi

if [ "$kubeadm_command" == 'cluster-join' ]; then
  step "Cluster Join"

  mkdir -p /etc/kubernetes/
  cp -r /vagrant/tmp/pki/ /etc/kubernetes/

  step "Show etcd CA certificate"
  openssl x509 -noout -in /etc/kubernetes/pki/etcd/ca.crt -issuer -subject -dates
  step "Show kubernetes CA certificate"
  openssl x509 -noout -in /etc/kubernetes/pki/ca.crt -issuer -subject -dates
  step "Show front-proxy-ca certificate"
  openssl x509 -noout -in /etc/kubernetes/pki/front-proxy-ca.crt -issuer -subject -dates

  source /vagrant/tmp/join-controlplane
fi

# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
#
# https://kubernetes.io/docs/concepts/cluster-administration/addons/

kubectl get node
