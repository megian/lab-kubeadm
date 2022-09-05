# lab-kubeadm

This is a [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) Kubernetes Cluster Lab wrapped in a Vagrant environment.

A friendly fork of [rgl/rke2-vagrant](https://github.com/rgl/rke2-vagrant). Thanks for all the prework!

# Usage

Check [libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt#installation) documentation for installation.

## Debian

Vagrant Debian:
```bash
sudo apt install vagrant
```

## Arch

Vagrant Arch:
```bash
sudo pacman -S vagrant libvirt pkg-config dnsmasq
```

Arch for NFS:
```bash
sudo pacman -S nfs-utils
```

Install the required vagrant plugins:

```bash
sudo vagrant plugin install vagrant-hosts vagrant-libvirt
```

Launch the environment:

```bash
time vagrant up --no-destroy-on-error --no-tty [--provider=libvirt]
```

**NB** The controlplane VMs (e.g. `cp1`) are [tainted](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) to prevent them from executing non control-plane workloads. That kind of workload is executed in the worker nodes (e.g. `w1`).

## Kubernetes API

Access the Kubernetes API at:

    https://vip.kubeadm.lab:6443


## K9s Dashboard (TODO)

The [K9s](https://github.com/derailed/k9s) console UI dashboard is also
installed in the controlplane node. You can access it by running:

```bash
vagrant ssh cp1
sudo su -l
k9s
```
