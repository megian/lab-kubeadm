#!/bin/bash
set -euxo pipefail

helm repo add headlamp https://headlamp-k8s.github.io/headlamp/

# now you should be able to install headlamp via helm
helm install my-headlamp headlamp/headlamp --namespace kube-system --set service.type=NodePort

kubectl -n kube-system create serviceaccount headlamp-admin
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin
#kubectl create token headlamp-admin -n kube-system

echo "1. Application URL for Headlamp:"
export NODE_PORT=$(kubectl get --namespace kube-system -o jsonpath="{.spec.ports[0].nodePort}" services my-headlamp)
export NODE_IP=$(kubectl get nodes --namespace kube-system -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT

echo "2. Token to login into Headlamp"
kubectl create token my-headlamp --namespace kube-system
