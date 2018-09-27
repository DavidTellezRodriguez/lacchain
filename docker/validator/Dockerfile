# Build Geth in a stock Go builder container
FROM golang:1.9-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git \
    && git clone https://github.com/alastria/quorum.git
WORKDIR quorum
RUN git checkout 99a83767ccf0384a3b58d9caffafabb5b49bd73c && make geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest
ENV IDENTITY = validator
RUN apk add --no-cache ca-certificates \
    && mkdir -p alastria/data
COPY --from=builder /go/quorum/build/bin/geth /usr/local/bin/

EXPOSE 21000 22000 30303 30303/udp
CMD ["sh","-c","geth init --datadir /alastria/data /alastria/data/genesis.json && geth --datadir /alastria/data --networkid 82584648529 --identity $IDENTITY --permissioned --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --rpcport 22000 --port 21000 --istanbul.requesttimeout 10000 --ethstats $IDENTITY:bb98a0b6442386d0cdf8a31b267892c1@35.231.29.1 --verbosity 3 --vmdebug --emitcheckpoints --targetgaslimit 18446744073709551615 --syncmode full --vmodule consensus/istanbul/core/core.go=5 --mine --minerthreads 1"]
