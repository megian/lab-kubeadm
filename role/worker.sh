#!/bin/bash
set -euxo pipefail

# configure the motd.
# NB this was generated at http://patorjk.com/software/taag/#p=display&f=Big&t=worker.
#    it could also be generated with figlet.org.
cat >/etc/motd <<'EOF'


                    | |                  
 __      _____  _ __| | _____ _ __       
 \ \ /\ / / _ \| '__| |/ / _ \ '__|      
  \ V  V / (_) | |  |   <  __/ |         
   \_/\_/ \___/|_|  |_|\_\___|_|         
                                         
                                         
EOF

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join vip.kubeadm.lab:6443 --token 92jejv.0ttc4uape9ogs6f4 \
#	--discovery-token-ca-cert-hash sha256:0e7c70a83734be41677c9d8c3a59a30f35971d28da6a490601251b449dd2feef 
