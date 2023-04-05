#!/usr/bin/env bash

# Note: Download updates to the VM
sudo apt update
sudo apt upgrade
sudo apt-get update
sudo apt-get upgrade
sudo apt install git build-essential ufw curl jq snapd wget --yes

# Note: Download go@1.19.1
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.19.1
(echo; echo 'eval "$(/home/.go)"') >> /home/adrian/.profile

# Note: Download Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/adrian/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# Note: Download and install the Gridiron Binary
git clone https://github.com/fanfury-sports/fanfury -b fanfury
cd fanfury
make install
cd ..

rm -rf ~/.fury

PASSWORD="F@nfuryG#n3sis@fury"
GAS_PRICES="0.000025utfury"
CHAIN_ID="gridiron_4200-3"
NODE="(fury tendermint show-node-id)"

fury init gridiron_4200-3 --chain-id $CHAIN_ID --staking-bond-denom utfury


# Note: Download the genesis file
curl -o ~/.fury/config/genesis.json https://raw.githubusercontent.com/fanfury-sports/download-1/main/testnet-1/genesis.json

# Note: Add an account
yes $PASSWORD | fury keys import GridironGuardian-2 ~/keys/GridironGuardian-2.key


# Set staking token (both bond_denom and mint_denom)
STAKING_TOKEN="utfury"
FROM="\"bond_denom\": \"stake\""
TO="\"bond_denom\": \"$STAKING_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json
FROM="\"mint_denom\": \"stake\""
TO="\"mint_denom\": \"$STAKING_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

# Set node3 token (both for gov min deposit and crisis constant node3)
FEE_TOKEN="utfury"
FROM="\"stake\""
TO="\"$FEE_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

# Set reserved bond tokens
RESERVED_BOND_TOKENS="" # example: " \"abc\", \"def\", \"ghi\" "
FROM="\"reserved_bond_tokens\": \[\]"
TO="\"reserved_bond_tokens\": \[$RESERVED_BOND_TOKENS\]"
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

# Set min-gas-prices (using node3 token)
FROM="minimum-gas-prices = \"\""
TO="minimum-gas-prices = \"0.000002$FEE_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

MAX_VOTING_PERIOD="90s" # example: "172800s"
FROM="\"voting_period\": \"172800s\""
TO="\"voting_period\": \"$MAX_VOTING_PERIOD\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json

yes $PASSWORD | fury gentx GridironGuardian-2 1000000utfury --chain-id $CHAIN_ID
fury collect-gentxs
fury validate-genesis

# Enable REST API
FROM="enable = false"
TO="enable = true"
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

# Enable Swagger docs
FROM="swagger = false"
TO="swagger = true"
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

# Broadcast node RPC endpoint
FROM="laddr = \"tcp:\/\/127.0.0.1:26657\""
TO="laddr = \"tcp:\/\/0.0.0.0:26657\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/config.toml

# Set timeouts to 1s for shorter block times
sed -i -e "s/timeout_commit = "5s"/timeout_commit = "1s"/g" "$HOME"/.fury/config/config.toml
sed -i -e "s/timeout_propose = "3s"/timeout_propose = "1s"/g" "$HOME"/.fury/config/config.toml


echo "The Gridiron Chain can now be started - Congratulation on being part of the Genesis!!"

