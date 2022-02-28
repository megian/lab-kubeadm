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

# Generate certificate if not exist
[ ! -f /vagrant/tmp/certificate-key ] && openssl rand -hex 32 > /vagrant/tmp/certificate-key

if [ "$kubeadm_command" == 'cluster-init' ]; then
  step "Cluster Init"

    #   n1: Image is up to date for k8s.gcr.io/kube-apiserver@sha256:add26e08df876fd8b92a53fab000bade34f624693f7944595776b75be17e5269
    # n1: Image is up to date for k8s.gcr.io/kube-controller-manager@sha256:21497e34aa9ac971040333d886e4755dbe5770310a1da233f83fecf28231f20e
    # n1: Image is up to date for k8s.gcr.io/kube-scheduler@sha256:32308abe86f7415611ca86ee79dd0a73e74ebecb2f9e3eb85fc3a8e62f03d0e7
    # n1: Image is up to date for k8s.gcr.io/pause@sha256:3d380ca8864549e74af4b29c10f9cb0956236dfb01c40ca076fb6c37253234db
    # n1: Image is up to date for k8s.gcr.io/etcd@sha256:05c1a3be66823dcaca55ebe17c3c9a60de7ceb948047da3e95308348325ddd5a
    # n1: Image is up to date for k8s.gcr.io/coredns/coredns@sha256:5b6ec0d6de9baaf3e92d0f66cd96a25b9edbce8716f5f15dcd1a616b3abd590e

  # https://docs.cilium.io/en/v1.11/gettingstarted/k8s-install-kubeadm/#create-the-cluster
  # https://docs.cilium.io/en/v1.11/gettingstarted/kubeproxy-free/#kubeproxy-free
  # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#uploading-control-plane-certificates-to-the-cluster
  kubeadm init --control-plane-endpoint vip.$(hostname --domain) --service-cidr 10.13.0.0/16 --skip-phases=addon/kube-proxy --upload-certs --certificate-key=$(cat /vagrant/tmp/certificate-key)
  # --pod-network-cidr 10.1.0.0/16

  # TODO: Check --upload-certs
  # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#uploading-control-plane-certificates-to-the-cluster

  # cluster-cidr: 10.12.0.0/16
  # service-cidr: 10.13.0.0/16  # default: 10.96.0.0/12
  # cluster-dns: 10.13.0.10  # default: 10.96.0.10
  # cluster-domain: cluster.local

  mkdir -p /vagrant/tmp
  join=$(kubeadm token create --print-join-command)

  # Unsecure control-plane token
  echo "$join --control-plane --certificate-key=$(cat /vagrant/tmp/certificate-key)" > /vagrant/tmp/join-controlplane
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

  #mkdir -p /etc/kubernetes/
  #cp -r /vagrant/tmp/pki/ /etc/kubernetes/

  #step "Show etcd CA certificate"
  #openssl x509 -noout -in /etc/kubernetes/pki/etcd/ca.crt -issuer -subject -dates
  #step "Show kubernetes CA certificate"
  #openssl x509 -noout -in /etc/kubernetes/pki/ca.crt -issuer -subject -dates
  #step "Show front-proxy-ca certificate"
  #openssl x509 -noout -in /etc/kubernetes/pki/front-proxy-ca.crt -issuer -subject -dates

  source /vagrant/tmp/join-controlplane
fi

# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
#
# https://kubernetes.io/docs/concepts/cluster-administration/addons/

kubectl get node