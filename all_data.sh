#!/usr/bin/env bash

PASSWORD="12345678"

grid init local --chain-id pandora-4

echo "Backing up existing genesis file..."
cp "$HOME"/.grid/config/genesis.json "$HOME"/.grid/config/genesis.json.backup

echo "Copying new genesis file to $HOME/.grid/config/genesis.json..."
cp genesis.json "$HOME"/.grid/config/genesis.json

yes 'y' | grid keys delete miguel --force
yes 'y' | grid keys delete francesco --force
yes 'y' | grid keys delete shaun --force
yes 'y' | grid keys delete fee --force
yes 'y' | grid keys delete fee2 --force
yes 'y' | grid keys delete fee3 --force
yes 'y' | grid keys delete fee4 --force
yes 'y' | grid keys delete fee5 --force
yes 'y' | grid keys delete reserveOut --force

yes $PASSWORD | grid keys add miguel
yes $PASSWORD | grid keys add francesco
yes $PASSWORD | grid keys add shaun
yes $PASSWORD | grid keys add fee
yes $PASSWORD | grid keys add fee2
yes $PASSWORD | grid keys add fee3
yes $PASSWORD | grid keys add fee4
yes $PASSWORD | grid keys add fee5
yes $PASSWORD | grid keys add reserveOut

# Note: important to add 'miguel' as a genesis-account since this is the chain's validator
yes $PASSWORD | grid add-genesis-account "$(grid keys show miguel -a)" 1000000000000ufury,1000000000000res,1000000000000rez,1000000000000uxgbp
yes $PASSWORD | grid add-genesis-account "$(grid keys show francesco -a)" 1000000000000ufury,1000000000000res,1000000000000rez
yes $PASSWORD | grid add-genesis-account "$(grid keys show shaun -a)" 1000000000000ufury,1000000000000res,1000000000000rez


# Set staking token (both bond_denom and mint_denom)
sed -i -e 's/stake/ufury/g' /home/adrian/.grid/config/genesis.json


# Set reserved bond tokens
RESERVED_BOND_TOKENS=""  # example: " \"abc\", \"def\", \"ghi\" "
FROM="\"reserved_bond_tokens\": \[\]"
TO="\"reserved_bond_tokens\": \[$RESERVED_BOND_TOKENS\]"
sed -i -e 's/$FROM/$TO/g' "$HOME"/.grid/config/genesis.json

# Set min-gas-prices (using fee token)
FROM="minimum-gas-prices = \"\""
TO="minimum-gas-prices = \"0.025$FEE_TOKEN\""
sed -i -e 's/$FROM/$TO/g' "$HOME"/.grid/config/app.toml

# TODO: config missing from new version (REF: https://github.com/cosmos/cosmos-sdk/issues/8529)
#grid config chain-id pandora-4
#grid config output json
#grid config indent true
#grid config trust-node true

grid gentx miguel 1000000ufury --chain-id pandora-4

grid collect-gentxs
grid validate-genesis

# Enable REST API (assumed to be at line 104 of app.toml)
FROM="enable = false"
TO="enable = true"
sed -i -e '104s/$FROM/$TO/g' "$HOME"/.grid/config/app.toml

# Enable Swagger docs (assumed to be at line 107 of app.toml)
FROM="swagger = false"
TO="swagger = true"
sed -i -e '107s/$FROM/$TO/g' "$HOME"/.grid/config/app.toml

# Uncomment the below to broadcast node RPC endpoint
#FROM="laddr = \"tcp:\/\/127.0.0.1:26657\""
#TO="laddr = \"tcp:\/\/0.0.0.0:26657\""
#sed -i "s/$FROM/$TO/" "$HOME"/.grid/config/config.toml

# Uncomment the below to set timeouts to 1s for shorter block times
#sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$HOME"/.grid/config/config.toml
#sed -i 's/timeout_propose = "3s"/timeout_propose = "1s"/g' "$HOME"/.grid/config/config.toml

grid start --pruning "nothing"
