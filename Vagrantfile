# to make sure the VM are created in order, we
# have to force a --no-parallel execution.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

require 'ipaddr'

# see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
kubeadm_version = '1.32*'
# see https://github.com/etcd-io/etcd/releases
# NB make sure you use a compatible version
# renovate: datasource=github-releases depName=etcd-io/etcd versioning=semver-coerced
etcd_version = 'v3.6.0'
# see https://github.com/derailed/k9s/releases
# renovate: datasource=github-releases depName=derailed/k9s versioning=semver-coerced
k9s_version = 'v0.50.6'
# see https://github.com/kubernetes-sigs/krew/releases
# renovate: datasource=github-releases depName=kubernetes-sigs/krew versioning=semver-coerced
krew_version = 'v0.4.5'

number_of_allinone_vm     = 3
number_of_controlplane_vm = 0
number_of_worker_vm       = 0

# https://de.wikipedia.org/wiki/Daisy_Chain
daisy_chain = 0

allinone_vip             = '10.11.0.5'
first_allinone_vm_ip     = '10.11.0.6'

controlplane_vip         = '10.11.0.5'
first_controlplane_vm_ip = '10.11.0.6'
worker_vip               = '10.11.0.10'
first_worker_vm_ip       = '10.11.0.11'

name_prefix_allinone_vm     = 'n'
name_prefix_controlplane_vm = 'cp'
name_prefix_worker_vm       = 'w'

allinone_vm_ip_address     = IPAddr.new first_controlplane_vm_ip
controlplane_vm_ip_address = IPAddr.new first_controlplane_vm_ip
worker_vm_ip_address       = IPAddr.new first_worker_vm_ip

cluster_domain   = 'kubeadm.lab'
cluster_vip_name = "vip.#{cluster_domain}"
cluster_k8s_api  = "https://#{cluster_vip_name}:6443"

application_domain = 'apps.kubeadm.lab'

Vagrant.configure(2) do |config|
  # https://app.vagrantup.com/debian
  config.vm.box = 'debian/bookworm64'

  # https://github.com/vagrant-libvirt/vagrant-libvirt
  config.vm.provider 'libvirt' do |lv, config|
    lv.cpus = 2
    lv.cpu_mode = 'host-passthrough'
    lv.nested = true
    lv.keymap = 'pt'
    lv.management_network_name = 'lab-kubeadm'
    config.vm.synced_folder '.', '/vagrant', type: 'nfs', nfs_version: '4.2', nfs_udp: false
  end

  ### ALL-IN-ONE VMs
  (1..number_of_allinone_vm).each do |n|
    name = "#{name_prefix_allinone_vm}#{n}"
    fqdn = "#{name}.#{cluster_domain}"
    ip_address = allinone_vm_ip_address.to_s; allinone_vm_ip_address = allinone_vm_ip_address.succ

    config.vm.define name do |config|
      config.vm.provider 'libvirt' do |lv, config|
        lv.memory = 2048
      end
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'hosts' do |hosts|
        hosts.autoconfigure = true
        hosts.sync_hosts = true
        hosts.add_localhost_hostnames = false
        hosts.add_host allinone_vip, [cluster_vip_name]
      end
      config.vm.provision 'shell', path: 'role/base.sh'
      config.vm.provision 'shell', path: 'role/helm.sh'
      config.vm.provision 'shell', path: 'role/allinone.sh'
      config.vm.provision 'shell', path: 'role/cri-o.sh'
      config.vm.provision 'shell', path: 'role/kube-vip.sh', args: [
        allinone_vip,
        'eth1',
      ]
      config.vm.provision 'shell', path: 'role/kubeadm.sh', args: [
        n == 1 ? "cluster-init" : "cluster-join",
        kubeadm_version,
      ]
      config.vm.provision 'shell', path: 'role/cilium-cli.sh'
      if n == 1
        config.vm.provision 'shell', path: 'role/cilium.sh'
      end
      
      config.vm.provision 'shell', path: 'role/etcdctl.sh', args: [etcd_version]
      config.vm.provision 'shell', path: 'role/k9s.sh', args: [k9s_version]

      if n == 3
        config.vm.provision 'shell', path: 'role/postconfig.sh'
        config.vm.provision 'shell', path: 'k8s/dex.sh'
        config.vm.provision 'shell', path: 'k8s/headlamp.sh'
        # config.vm.provision 'shell', path: 'k8s/example-app.sh'
      end
      config.vm.provision 'shell', path: 'role/crictl.sh'
      config.vm.provision 'shell', path: 'role/show.sh'
    end
  end

  ### CONTROLPLANE VMs
  (1..number_of_controlplane_vm).each do |n|
    name = "#{name_prefix_controlplane_vm}#{n}"
    fqdn = "#{name}.#{cluster_domain}"
    ip_address = controlplane_vm_ip_address.to_s; controlplane_vm_ip_address = controlplane_vm_ip_address.succ

    config.vm.define name do |config|
      config.vm.provider 'libvirt' do |lv, config|
        lv.memory = 1024
      end
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'hosts' do |hosts|
        hosts.autoconfigure = true
        hosts.sync_hosts = true
        hosts.add_localhost_hostnames = false
        hosts.add_host controlplane_vip, [cluster_vip_name]
      end
      config.vm.provision 'shell', path: 'role/base.sh'
      config.vm.provision 'shell', path: 'role/helm.sh'
      config.vm.provision 'shell', path: 'role/controlplane.sh'
      config.vm.provision 'shell', path: 'role/cri-o.sh'
      config.vm.provision 'shell', path: 'role/kube-vip.sh', args: [
        allinone_vip,
        'eth1',
      ]
    end
  end

  ### WORKER VMs
  (1..number_of_worker_vm).each do |n|
    name = "#{name_prefix_worker_vm}#{n}"
    fqdn = "#{name}.#{cluster_domain}"
    ip_address = worker_vm_ip_address.to_s; worker_vm_ip_address = worker_vm_ip_address.succ

    config.vm.define name do |config|
      config.vm.provider 'libvirt' do |lv, config|
        lv.memory = 2*1024
      end
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'hosts' do |hosts|
        hosts.autoconfigure = true
        hosts.sync_hosts = true
        hosts.add_localhost_hostnames = false
        hosts.add_host first_controlplane_vm_ip, [cluster_vip]
      end
      config.vm.provision 'shell', path: 'role/base.sh'
      config.vm.provision 'shell', path: 'role/helm.sh'
      config.vm.provision 'shell', path: 'role/worker.sh'
      config.vm.provision 'shell', path: 'role/cri-o.sh'
    end
  end
end
