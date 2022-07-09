#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath -s $0))
cd ${SCRIPT_PATH}
set -o allexport
source .env
source ../utilities/rainbow.sh
set +o allexport

~/utilities/create-data-volume.sh

wget https://dist.ipfs.io/go-ipfs/v${IPFS_VERSION}/go-ipfs_v${IPFS_VERSION}_linux-amd64.tar.gz &&
tar xvfz go-ipfs_v${IPFS_VERSION}_linux-amd64.tar.gz &&
rm go-ipfs_v${IPFS_VERSION}_linux-amd64.tar.gz &&
sudo mv go-ipfs/ipfs /usr/local/bin &&
rm -rf go-ipfs

ipfs init &&
sed -i s#127.0.0.1/tcp/5001#0.0.0.0/tcp/5001#g /data/gitblox/config

sudo cp ./ipfs.service /etc/systemd/system/
sudo systemctl enable ipfs
sudo systemctl start ipfs

echo "deployed"