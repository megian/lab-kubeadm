#!/bin/sh
# curl -OLs https://github.com/.tar.gz

# root@n1:~# kubeadm config images pull
# root@n1:~# crictl images
# IMAGE                                     TAG                 IMAGE ID            SIZE
# ghcr.io/dexidp/dex                        latest-distroless   e5de657f62278       162MB
# ghcr.io/kube-vip/kube-vip                 v1.2.4              d37d19befda3a       61.1MB
# quay.io/cilium/cilium-envoy               <none>              18f3aea3c0c65       203MB
# quay.io/cilium/cilium                     <none>              09fc98d1b2d27       756MB
# quay.io/cilium/operator-generic           <none>              5847b20e503f7       117MB
# registry.k8s.io/coredns/coredns           v1.14.6             520212b8b0fcd       78.5MB
# registry.k8s.io/etcd                      3.7.0-0             270fbeb697171       61.2MB
# registry.k8s.io/kube-apiserver            v1.37.1             82ae6c548117f       104MB
# registry.k8s.io/kube-controller-manager   v1.37.1             336e72df967a8       91.1MB
# registry.k8s.io/kube-scheduler            v1.37.1             45eb9287e2328       62.7MB
# registry.k8s.io/pause                     3.10.2              4a83b15d3ecfe       742kB
