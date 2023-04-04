#!/usr/bin/env bash

PASSWORD="F@nfuryG#n3sis@fury"
rm -rf ~/.fury

PASSWORD="F@nfuryG#n3sis@fury"
GAS_PRICES="0.000025utfury"
CHAIN_ID="gridiron_4200-3"
NODE="(fury tendermint show-node-id)"

fury init gridiron_4200-3 --chain-id $CHAIN_ID --staking-bond-denom utfury

# Note: Download the genesis file
curl -o ~/.fury/config/genesis.json https://raw.githubusercontent.com/gridironzone/gridtestnet-1/master/testnet-1/genesis.json

# Import keys into Fury
yes $PASSWORD | fury keys import GridironGuardian-2 ~/keys/GridironGuardian-2.key
yes $PASSWORD | fury keys import genArgentina ~/keys/genArgentina.key
yes $PASSWORD | fury keys import genBrazil ~/keys/genBrazil.key
yes $PASSWORD | fury keys import genBrooklyn-Nets ~/keys/genBrooklyn.key
yes $PASSWORD | fury keys import genBuffallo-Bills ~/keys/genBuffallo.key
yes $PASSWORD | fury keys import genIndia-Football ~/keys/genIndia.key
yes $PASSWORD | fury keys import genLA-Lakers ~/keys/genLA.key
yes $PASSWORD | fury keys import genNY-Yankees ~/keys/genNY.key
yes $PASSWORD | fury keys import genPSG ~/keys/genPSG.key
yes $PASSWORD | fury keys import genSF-Giants genSF.key
yes $PASSWORD | fury keys import node0 ~/keys/node0.key
yes $PASSWORD | fury keys import node1 ~/keys/node1.key
yes $PASSWORD | fury keys import node2 ~/keys/node2.key
yes $PASSWORD | fury keys import node3 ~/keys/node3.key
yes $PASSWORD | fury keys import node4 ~/keys/node4.key
yes $PASSWORD | fury keys import node5 ~/keys/node5.key
yes $PASSWORD | fury keys import node6 ~/keys/node6.key
yes $PASSWORD | fury keys import node7 ~/keys/node7.key
yes $PASSWORD | fury keys import node8 ~/keys/node8.key
yes $PASSWORD | fury keys import sentry1 ~/keys/sentry1.key
yes $PASSWORD | fury keys import sentry2 ~/keys/sentry2.key
yes $PASSWORD | fury keys import sentry3 ~/keys/sentry3.key
yes $PASSWORD | fury keys import sentry4 ~/keys/sentry4.key


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
TO="minimum-gas-prices = \"0.025$FEE_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/app.toml

MAX_VOTING_PERIOD="90s" # example: "172800s"
FROM="\"voting_period\": \"172800s\""
TO="\"voting_period\": \"$MAX_VOTING_PERIOD\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json



yes $PASSWORD | fury gentx node0 100000000utfury --chain-id $CHAIN_ID
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


echo "fury can now be started!!"


