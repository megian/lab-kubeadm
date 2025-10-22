#!/bin/sh
# curl -OLs https://github.com/.tar.gz

# root@n1:~# kubeadm config images pull
# root@n1:~# crictl images
# IMAGE                                     TAG                 IMAGE ID            SIZE
# ghcr.io/dexidp/dex                        latest-distroless   c5489cc2b85ba       136MB
# ghcr.io/kube-vip/kube-vip                 v1.0.1              ce5ff7916975f       61.7MB
# quay.io/cilium/cilium-envoy               <none>              686dbde4b7c46       190MB
# quay.io/cilium/cilium                     <none>              d17ba2d17aae4       761MB
# quay.io/cilium/operator-generic           <none>              4608cb7081a27       117MB
# registry.k8s.io/coredns/coredns           v1.12.1             52546a367cc9e       76.1MB
# registry.k8s.io/etcd                      3.6.4-0             5f1f5298c888d       196MB
# registry.k8s.io/kube-apiserver            v1.34.1             c3994bc696102       89MB
# registry.k8s.io/kube-controller-manager   v1.34.1             c80c8dbafe7dd       76MB
# registry.k8s.io/kube-scheduler            v1.34.1             7dd6aaa1717ab       53.8MB
# registry.k8s.io/pause                     3.10.1              cd073f4c5f6a8       742kB
