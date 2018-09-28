#!/bin/bash

#
# This is used to run the constellation and geth node
#

set -u
set -e

### Configuration Options
TMCONF=/alastria/configuration.conf

GETH_ARGS="--datadir /alastria/data --networkid 82584648529 --identity $IDENTITY --permissioned --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --rpcport 22000 --port 21000 --istanbul.requesttimeout 10000 --ethstats $IDENTITY:bb98a0b6442386d0cdf8a31b267892c1@35.231.29.1 --verbosity 3 --vmdebug --emitcheckpoints --targetgaslimit 18446744073709551615 --syncmode full --vmodule consensus/istanbul/core/core.go=5 --mine --minerthreads 1"

if [ ! -d /alastria/data/constellation ]; then
  mkdir -p /alastria/data/constellation/{data,keystore}
  mkdir -p /alastria/logs
fi

if [ ! -d /alastria/data/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /alastria/data init /alastria/data/genesis.json
fi

if [ ! -e /alastria/data/constellation/keystore/node.pub ]; then
  echo "[*] Generating constellation keys"
  cd /alastria/data/constellation/keystore
  cat /alastria/.account_pass | constellation-node --generatekeys=node
fi

echo "[*] Starting Constellation node"
nohup /usr/local/bin/constellation-node $TMCONF 2>> /alastria/logs/constellation.log &

sleep 5

echo "[*] Starting node"
PRIVATE_CONFIG=$TMCONF nohup /usr/local/bin/geth $GETH_ARGS 2>>/alastria/logs/geth.log