#!/bin/bash

if [[ -f "./export-genesis.json" ]]
then
    echo 'Already has export-genesis.json exported. Nothing to do!'
    exit
fi

if [ $NEED_TO_RUN -eq 1 ]
then
    # run the binary in background
    fury start

    sleep 10 && pkill fury
fi
# export genesis state to file
fury export 2>&1 | tee export-genesis.json