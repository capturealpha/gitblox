#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath -s $0))
cd ${SCRIPT_PATH}
set -o allexport
source .env
source ../utilities/rainbow.sh
set +o allexport

~/utilities/create-data-volume.sh

# Configure git repository
if [ ! -d "${DATA_DIR}/test-repo" ]; then
    mkdir -p ${DATA_DIR}/test-repo
    cd ${DATA_DIR}/test-repo
    git init . --bare --shared
    git update-server-info
    git config --bool http.receivepack true
    sudo chmod -R ugo+rw .
fi

cd ${SCRIPT_PATH}
if [ -f  "${SCRIPT_PATH}/nginx.conf" ]; then
    sed -i s#%DATA_DIR%#${DATA_DIR}#g ./nginx.conf &&
    sudo mv ./nginx.conf /etc/nginx/sites-available/default
fi

sudo systemctl enable fcgiwrap
sudo systemctl enable nginx

sudo systemctl restart fcgiwrap
sudo systemctl restart nginx

sleep 5

if [ ! -d "${SCRIPT_PATH}/git-test" ]; then
    mkdir git-test
    cd git-test
    git init
    git remote add origin http://localhost/test-repo
    git config --global user.email "test@gitblox.io"
    git config --global user.name "Gitblox Test"
    mkdir test
    echo "This is my first file" > test/test.txt
    git add .
    git commit -a -m "Add test file and directory"
    git push --set-upstream origin master
fi

echogreen "deployment completed!"