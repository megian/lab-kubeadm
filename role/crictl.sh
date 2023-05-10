#!/bin/bash
set -euxo pipefail

# install the bash completion scripts.
crictl completion bash >/usr/share/bash-completion/completions/crictl

# Cleaning CRI-O storage https://docs.openshift.com/container-platform/4.12/support/troubleshooting/troubleshooting-crio-issues.html
