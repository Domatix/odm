#!/usr/bin/env bash
#### Written by: Catalin Airimitoaie - catalin@domatix.com
#### Description: ODM build script. Do not call this script directly, it will be ran by `run.sh` in order to build a new development instance

cd $1
if ! docker image ls | grep "domatix/odoo" | grep "base"; then
	docker build -t domatix/odoo:base ../../dockerfiles/base
fi

source .env
docker-compose build --no-cache
sudo chown -R $USER:$USER $etc_path/../
touch $etc_path/run.pid
cp $( cd "$(dirname "$0")" ; pwd -P )/../../helper-scripts/* $etc_path
