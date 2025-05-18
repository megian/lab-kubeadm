#!/bin/sh
# curl -OLs https://github.com/.tar.gz

# root@n1:~# kubeadm config images pull
# root@n1:~# crictl images
# IMAGE                                     TAG                 IMAGE ID            SIZE
# ghcr.io/dexidp/dex                        latest-distroless   04e8e47937a59       126MB
# ghcr.io/kube-vip/kube-vip                 v0.9.1              999ea582920af       58.5MB
# quay.io/cilium/cilium-envoy               <none>              ebcf7d5ca03c4       171MB
# quay.io/cilium/cilium                     <none>              59d2eae9f28d8       821MB
# quay.io/cilium/operator-generic           <none>              70237538a05d7       126MB
# registry.k8s.io/coredns/coredns           v1.12.0             1cf5f116067c6       71.2MB
# registry.k8s.io/etcd                      3.5.21-0            499038711c081       154MB
# registry.k8s.io/kube-apiserver            v1.33.1             c6ab243b29f82       103MB
# registry.k8s.io/kube-controller-manager   v1.33.1             ef43894fa110c       95.7MB
# registry.k8s.io/kube-scheduler            v1.33.1             398c985c0d950       74.5MB
# registry.k8s.io/pause                     3.10                873ed75102791       742kB
