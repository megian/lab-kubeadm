#!/bin/sh
# curl -OLs https://github.com/.tar.gz

# root@n1:~# kubeadm config images pull
# root@n1:~# crictl images
# IMAGE                                     TAG                 IMAGE ID            SIZE
# ghcr.io/kube-vip/kube-vip                 v0.8.3              18b729c2288dc       50.1MB
# quay.io/cilium/cilium                     <none>              119e6111c0e41       623MB
# quay.io/cilium/operator-generic           <none>              d3cf9fb7f3cba       105MB
# registry.k8s.io/coredns/coredns           v1.11.3             c69fa2e9cbf5f       63.3MB
# registry.k8s.io/etcd                      3.5.15-0            2e96e5913fc06       149MB
# registry.k8s.io/kube-apiserver            v1.30.5             e9adc5c075a83       118MB
# registry.k8s.io/kube-controller-manager   v1.30.5             38406042cf085       112MB
# registry.k8s.io/kube-scheduler            v1.30.5             25903461e65c3       63.1MB
# registry.k8s.io/pause                     3.9                 e6f1816883972       750kB
