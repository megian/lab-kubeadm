#!/bin/bash
set -euxo pipefail

curl -sL https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/helm.gpg > /dev/null
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
