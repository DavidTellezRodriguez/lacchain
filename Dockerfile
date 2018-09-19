# Build Geth in a stock Go builder container
FROM golang:1.9-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git \
    && git clone https://github.com/alastria/quorum.git
WORKDIR quorum
RUN git checkout 99a83767ccf0384a3b58d9caffafabb5b49bd73c && make geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates \
    && mkdir -p alastria/data
COPY --from=builder /go/quorum/build/bin/geth /usr/local/bin/
COPY roles/alastria-validator-node/files/*.json /alastria/data/
RUN mv /alastria/data/permissioned-nodes_validator.json /alastria/data/permissioned-nodes.json \
    && geth init --datadir /alastria/data /alastria/data/genesis.json

EXPOSE 21000 22000 30303 30303/udp
ENTRYPOINT ["geth"]