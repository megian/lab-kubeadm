#!/bin/sh
# curl -OLs https://github.com/.tar.gz

# root@n1:~# kubeadm config images pull
# root@n1:~# crictl images
# IMAGE                                     TAG                 IMAGE ID            SIZE
# ghcr.io/dexidp/dex                        latest-distroless   bcffc6984b028       136MB
# ghcr.io/kube-vip/kube-vip                 v1.0.3              d001ad15d6bc8       62.1MB
# quay.io/cilium/cilium-envoy               <none>              a30b64b9f8378       181MB
# quay.io/cilium/cilium                     <none>              443f0e7d02324       720MB
# quay.io/cilium/operator-generic           <none>              f7669f7f90730       117MB
# registry.k8s.io/coredns/coredns           v1.13.1             aa5e3ebc0dfed       79.2MB
# registry.k8s.io/etcd                      3.6.6-0             0a108f7189562       63.6MB
# registry.k8s.io/kube-apiserver            v1.35.0             5c6acd67e9cd1       90.8MB
# registry.k8s.io/kube-controller-manager   v1.35.0             2c9a4b058bd7e       76.9MB
# registry.k8s.io/kube-scheduler            v1.35.0             550794e3b12ac       52.8MB
# registry.k8s.io/pause                     3.10.1              cd073f4c5f6a8       742kB
