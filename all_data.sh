#!/usr/bin/env bash

PASSWORD="F@nfuryG#n3sis@fury"

fury init local --chain-id gridiron_4200-1001

yes $PASSWORD | fury keys add genArgentina
yes $PASSWORD | fury keys add genBrazil
yes $PASSWORD | fury keys add genBrooklyn-Nets
yes $PASSWORD | fury keys add genIndia-Football
yes $PASSWORD | fury keys add genLA-Lakers
yes $PASSWORD | fury keys add genNY-Yankees
yes $PASSWORD | fury keys add genSF-Giants

# Note: important to add 'genBrazil' as a genesis-account since this is the chain's validator
yes $PASSWORD | fury add-genesis-account "$(fury keys show genArgentina -a)" 120000020000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genBrazil -a)" 30537820000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genBrooklyn-Nets -a)" 25000000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genIndia-Football -a)" 200000000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genLA-Lakers -a)" 132572320000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genNY-Yankees -a)" 200066960000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genSF-Giants -a)" 23264580000utfury


# Set staking token (both bond_denom and mint_denom)
sed -i -e 's/stake/utfury/g' /home/adrian/.fury/config/genesis.json


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
#fury config chain-id gridiron_4200-1001
#fury config output json
#fury config indent true
#fury config trust-node true

fury gentx genBrazil 1000000utfury --chain-id gridiron_4200-1001

fury collect-gentxs
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

# fury start --pruning "nothing"
echo "You're good to go!!"