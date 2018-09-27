#!/bin/bash

#
# This is used to run the constellation and geth node
#

set -u
set -e

### Configuration Options
TMCONF=/alastria/data/tm.conf

GETH_ARGS="--datadir /alastria/data --raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover"

if [ ! -d /alastria/data/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /alastria/data init /alastria/data/genesis.json
fi

echo "[*] Starting Constellation node"
nohup /usr/local/bin/constellation-node $TMCONF 2>> /alastria/logs/constellation.log &

sleep 5

echo "[*] Starting node"
PRIVATE_CONFIG=$TMCONF nohup /usr/local/bin/geth $GETH_ARGS 2>>/alastria/logs/geth.log