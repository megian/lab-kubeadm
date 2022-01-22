#!/bin/bash
set -euxo pipefail

# configure the motd.
# NB this was generated at http://patorjk.com/software/taag/#p=display&f=Big&t=all-in-one.
#    it could also be generated with figlet.org.
cat >/etc/motd <<'EOF'

        _ _        _                             
       | | |      (_)                            
   __ _| | |______ _ _ __ ______ ___  _ __   ___ 
  / _` | | |______| | '_ \______/ _ \| '_ \ / _ \
 | (_| | | |      | | | | |    | (_) | | | |  __/
  \__,_|_|_|      |_|_| |_|     \___/|_| |_|\___|
                                                 
                                                 

EOF

APT_PACKAGES=""

# Install jq
APT_PACKAGES+=" jq"

# Install the bash completion
APT_PACKAGES+=" bash-completion"

# install packages
apt-get install -y --no-install-recommends $APT_PACKAGES
