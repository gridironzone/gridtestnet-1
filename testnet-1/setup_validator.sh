#!/bin/sh

# Set parameters

CHAIN_ID=${CHAIN_ID:-"gridiron_4200-3"}
MONIKER_NAME=${MONIKER_NAME:-"GridironGuardian"}
KEY_NAME=${KEY_NAME:-"genArgentina"}

NODE_AMOUNT=${NODE_AMOUNT:-"20000000utfury"}
NODE_STAKING_AMOUNT=${NODE_STAKING_AMOUNT:-"10000000utfury"}

query_balance() {
 NODE_ACCOUNT="$(fury keys show -a "$KEY_NAME" --keyring-backend os)"
    echo "Current balance of the full node account on chain[$NODE_ACCOUNT]: "
    fury q bank balances "$NODE_ACCOUNT"

    echo "Make sure the sequencer account [$NODE_ACCOUNT] is funded"
    echo "From within the hub node: \"fury tx bank send $KEY_NAME $NODE_ACCOUNT $NODE_AMOUNT --keyring-backend os\""
    read -r -p "Press to continue..."
}

create_validator() {
    echo "Current balance of the full node account on chain[$NODE_ACCOUNT]: "
    fury q bank balances "$NODE_ACCOUNT"

    echo `# ------------------- Running create-validator transaction ------------------- #`
    fury tx staking create-validator \
        --amount "$NODE_STAKING_AMOUNT" \
        --commission-max-change-rate "0.1" \
        --commission-max-rate "0.20" \
        --commission-rate "0.1" \
        --min-self-delegation "1" \
        --details "validators write bios too" \
        --pubkey=$(fury tendermint show-validator) \
        --moniker "2ndmoniker" \
        --chain-id "$CHAIN_ID" \
        --gas-prices 0.025utfury \
        --from "$KEY_NAME" \
        --keyring-backend os
}


query_balance
create_validator