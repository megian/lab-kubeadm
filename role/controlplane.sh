#!/bin/bash
set -euxo pipefail

# configure the motd.
# NB this was generated at http://patorjk.com/software/taag/#p=display&f=Big&t=control-plane.
#    it could also be generated with figlet.org.
cat >/etc/motd <<'EOF'

                  _             _              _                  
                 | |           | |            | |                 
   ___ ___  _ __ | |_ _ __ ___ | |______ _ __ | | __ _ _ __   ___ 
  / __/ _ \| '_ \| __| '__/ _ \| |______| '_ \| |/ _` | '_ \ / _ \
 | (_| (_) | | | | |_| | | (_) | |      | |_) | | (_| | | | |  __/
  \___\___/|_| |_|\__|_|  \___/|_|      | .__/|_|\__,_|_| |_|\___|
                                        | |                       
                                        |_|                       

EOF

APT_PACKAGES=""

# Install jq
APT_PACKAGES+=" jq"

# Install the bash completion
APT_PACKAGES+=" bash-completion"

# install packages
apt-get install -y --no-install-recommends $APT_PACKAGES
