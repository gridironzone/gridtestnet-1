#!/bin/bash

NEED_TO_RUN=${NEED_TO_RUN:-1}
RPC_PORT=${RPC_PORT:-26657}
GRPC_PORT=${GRPC_PORT:-9090}
P2P_PORT=${P2P_PORT:-26656}
REST_PORT=${REST_PORT:-1317}

sed -i -e '0,/address/s/address *= *.*/address = \"tcp:\/\/0.0.0.0:$REST_PORT\"/g' .fury/config/app.toml 

# reference: https://stackoverflow.com/a/9453461

if [[ -f "./export-genesis.json" ]]
then
    echo 'Already has export-genesis.json exported. Nothing to do!'
    exit
fi

if [ $NEED_TO_RUN -eq 1 ]
then
    # run the binary in background
    fury start --p2p.laddr tcp://0.0.0.0:26656 --grpc.address 0.0.0.0:9090 --rpc.laddr tcp://0.0.0.0:26657 &

    sleep 10 && pkill fury
fi
# export genesis state to file
fury export 2>&1 | tee export-genesis.json