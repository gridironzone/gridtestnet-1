#!/usr/bin/env bash

rm rf ~/.fury

PASSWORD="F@nfuryG#n3sis@fury"

fury init gridiron --chain-id gridiron_4200-3 --staking-bond-denom utfury


yes $PASSWORD | fury keys add GridironGuardian-1
yes $PASSWORD | fury keys add GridironGuardian-2

yes $PASSWORD | fury keys add genArgentina
yes $PASSWORD | fury keys add senArgentina-1
yes $PASSWORD | fury keys add senArgentina-2
yes $PASSWORD | fury keys add senArgentina-3
yes $PASSWORD | fury keys add senArgentina-4
yes $PASSWORD | fury keys add nodeArg-1
yes $PASSWORD | fury keys add nodeArg-2

yes $PASSWORD | fury add-genesis-account "$(fury keys show genArgentina -a)" 120000020000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show GridironGuardian-1 -a)" 10000000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show GridironGuardian-2 -a)" 10000000000utfury


# Set staking token (both bond_denom and mint_denom)
STAKING_TOKEN="utfury"
FROM="\"bond_denom\": \"stake\""
TO="\"bond_denom\": \"$STAKING_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json
FROM="\"mint_denom\": \"stake\""
TO="\"mint_denom\": \"$STAKING_TOKEN\""
sed -i -e "s/$FROM/$TO/" "$HOME"/.fury/config/genesis.json


# Set reserved bond tokens
RESERVED_BOND_TOKENS=""  # example: " \"abc\", \"def\", \"ghi\" "
FROM="\"reserved_bond_tokens\": \[\]"
TO="\"reserved_bond_tokens\": \[$RESERVED_BOND_TOKENS\]"
sed -i -e 's/$FROM/$TO/g' "$HOME"/.fury/config/genesis.json

# Set min-gas-prices (using genIndia-Football token)
FROM="minimum-gas-prices = \"\""
TO="minimum-gas-prices = \"0.025$FEE_TOKEN\""
sed -i -e 's/$FROM/$TO/g' "$HOME"/.fury/config/app.toml

# TODO: config missing from new version (REF: https://github.com/cosmos/cosmos-sdk/issues/8529)
#fury config chain-id gridiron_4200-3
#fury config output json
#fury config indent true
#fury config trust-node true

fury gentx genArgentina 1000000utfury --chain-id gridiron_4200-3
fury validate-genesis

# Enable REST API (assumed to be at line 104 of app.toml)
FROM="enable = false"
TO="enable = true"
sed -i -e '104s/$FROM/$TO/g' "$HOME"/.fury/config/app.toml

# Enable Swagger docs (assumed to be at line 107 of app.toml)
FROM="swagger = false"
TO="swagger = true"
sed -i -e '107s/$FROM/$TO/g' "$HOME"/.fury/config/app.toml

# Uncomment the below to broadcast node RPC endpoint
FROM="laddr = \"tcp:\/\/127.0.0.1:26657\""
TO="laddr = \"tcp:\/\/0.0.0.0:26657\""
sed -i -e '107s/$FROM/$TO/g' "$HOME"/.fury/config/app.toml

# Uncomment the below to set timeouts to 1s for shorter block times
sed -i -e 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$HOME"/.fury/config/config.toml
sed -i -e 's/timeout_propose = "3s"/timeout_propose = "1s"/g' "$HOME"/.fury/config/config.toml

yes $PASSWORD | fury keys export GridironGuardian-1
yes $PASSWORD | fury keys export GridironGuardian-2

yes $PASSWORD | fury keys export genArgentina
yes $PASSWORD | fury keys export senArgentina-1
yes $PASSWORD | fury keys export senArgentina-2
yes $PASSWORD | fury keys export senArgentina-3
yes $PASSWORD | fury keys export senArgentina-4
yes $PASSWORD | fury keys export nodeArg-1
yes $PASSWORD | fury keys export nodeArg-2