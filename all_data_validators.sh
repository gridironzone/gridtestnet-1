#!/usr/bin/env bash

rm rf ~/.fury

PASSWORD="F@nfuryG#n3sis@fury"

fury init gridiron --chain-id gridiron_4200-3 --staking-bond-denom utfury


yes $PASSWORD | fury keys add GridironGuardian-1
yes $PASSWORD | fury keys add GridironGuardian-2
yes $PASSWORD | fury keys add genArgentina
yes $PASSWORD | fury keys add genBrazil
yes $PASSWORD | fury keys add genBrooklyn-Nets
yes $PASSWORD | fury keys add genBuffallo-Bills
yes $PASSWORD | fury keys add genIndia-Football
yes $PASSWORD | fury keys add genLA-Lakers
yes $PASSWORD | fury keys add genNY-Yankees
yes $PASSWORD | fury keys add genPSG
yes $PASSWORD | fury keys add genSF-Giants
yes $PASSWORD | fury keys add node0
yes $PASSWORD | fury keys add node1
yes $PASSWORD | fury keys add node2
yes $PASSWORD | fury keys add node3
yes $PASSWORD | fury keys add node4
yes $PASSWORD | fury keys add node5
yes $PASSWORD | fury keys add node6
yes $PASSWORD | fury keys add node7
yes $PASSWORD | fury keys add node8
yes $PASSWORD | fury keys add sentry1
yes $PASSWORD | fury keys add sentry2
yes $PASSWORD | fury keys add sentry3
yes $PASSWORD | fury keys add sentry4

# Note: important to add 'genBrazil' as a genesis-account since this is the chain's validator
yes $PASSWORD | fury add-genesis-account "$(fury keys show GridironGuardian-1 -a)" 100000000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show GridironGuardian-2 -a)" 100000000000utfury

yes $PASSWORD | fury add-genesis-account "$(fury keys show genArgentina -a)" 120000020000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genBrazil -a)" 30537820000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genBrooklyn-Nets -a)" 25000000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genBrooklyn-Nets -a)" 200000000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genIndia-Football -a)" 132572320000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genLA-Lakers -a)" 200066960000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genNY-Yankees -a)" 23264580000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genNY-Yankees -a)" 200000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show genSF-Giants -a)" 100000000000utfury

yes $PASSWORD | fury add-genesis-account "$(fury keys show node0 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node1 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node2 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node3 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node4 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node5 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node6 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node7 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show node8 -a)" 100000000utfury

yes $PASSWORD | fury add-genesis-account "$(fury keys show sentry1 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show sentry2 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show sentry3 -a)" 100000000utfury
yes $PASSWORD | fury add-genesis-account "$(fury keys show sentry4 -a)" 100000000utfury


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

yes $PASSWORD | fury keys export GridironGuardian-2
yes $PASSWORD | fury keys export genArgentina
yes $PASSWORD | fury keys export genBrazil
yes $PASSWORD | fury keys export genBrooklyn-Nets
yes $PASSWORD | fury keys export genBuffallo-Bills
yes $PASSWORD | fury keys export genIndia-Football
yes $PASSWORD | fury keys export genLA-Lakers
yes $PASSWORD | fury keys export genNY-Yankees
yes $PASSWORD | fury keys export genPSG
yes $PASSWORD | fury keys export genSF-Giants
yes $PASSWORD | fury keys export node0
yes $PASSWORD | fury keys export node1
yes $PASSWORD | fury keys export node2
yes $PASSWORD | fury keys export node3
yes $PASSWORD | fury keys export node4
yes $PASSWORD | fury keys export node5
yes $PASSWORD | fury keys export node6
yes $PASSWORD | fury keys export node7
yes $PASSWORD | fury keys export node8
yes $PASSWORD | fury keys export sentry1
yes $PASSWORD | fury keys export sentry2
yes $PASSWORD | fury keys export sentry3
yes $PASSWORD | fury keys export sentry4

echo "
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
 	                      You're all set!!!!						
		The Gridiron Chain will now be started!!         
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###                                											###
###############################################################################
###############################################################################
###############################################################################
###############################################################################
"

fury start