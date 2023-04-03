#!/usr/bin/env bash

# Must be run from root path inside fury-blockchain for source to work

# Note: update all dependencies
sudo apt update
sudo apt upgrade
sudo apt-get update
sudo apt-get upgrade
sudo apt install git build-essential ufw curl jq snapd wget --yes

# Note: install go@v1.19.1
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.19.1
source /home/adrian/.bashrc

# Note: install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Note: Add Homebrew to bin
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/adrian/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Note: Download and install the Gridiron Zone Binary
git clone https://github.com/furynet/furyhub -b genesis 
cd furyhub
make install
cd ..
