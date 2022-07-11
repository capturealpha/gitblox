#!/bin/bash

sudo file -s /dev/nvme1n1 | grep "/dev/nvme1n1: data" &&
sudo mkfs -t xfs /dev/nvme1n1
if ! df -h | grep "/data"; then
    sudo mkdir -p /data &&
    sudo mount /dev/nvme1n1 /data &&
    echo "/dev/nvme1n1 /data xfs defaults 0 2" | sudo tee -a /etc/fstab &&
    sudo mkdir -p /data/ipfa &&
    sudo chown -R ${USER}:${USER} /data/ &&
    sudo chmod -R ugo+rw /data/
fi
