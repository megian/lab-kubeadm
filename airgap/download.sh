#!/bin/sh
# curl -OLs https://github.com/.tar.gz

# root@n1:~# kubeadm config images pull
# root@n1:~# crictl images
# IMAGE                                     TAG                 IMAGE ID            SIZE
# ghcr.io/kube-vip/kube-vip                 v0.8.3              18b729c2288dc       50.1MB
# quay.io/cilium/cilium-envoy               <none>              b9d596d6e2d4f       165MB
# quay.io/cilium/cilium                     <none>              119e6111c0e41       623MB
# registry.k8s.io/coredns/coredns           v1.11.3             c69fa2e9cbf5f       63.3MB
# registry.k8s.io/etcd                      3.5.15-0            2e96e5913fc06       152MB
# registry.k8s.io/kube-apiserver            v1.31.0             604f5db92eaa8       95.2MB
# registry.k8s.io/kube-controller-manager   v1.31.0             045733566833c       89.4MB
# registry.k8s.io/kube-scheduler            v1.31.0             1766f54c897f0       68.4MB
# registry.k8s.io/pause                     3.10                873ed75102791       742kB
