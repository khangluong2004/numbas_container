#!/bin/bash
set -e

if [ ! -d "./numbas-lti-provider-docker" ]; then
    echo "Cloning Numbas LTI provider Docker repository..."
    git clone https://github.com/numbas/numbas-lti-provider-docker.git
fi

cd ./numbas-lti-provider-docker
echo "Building container for numbas-lti"
docker build . -t numbas/numbas-lti-provider

echo "Running installation script..."
docker compose run --rm numbas-setup python ./install

echo "Starting Numbas LTI provider..."
docker compose up --scale daphne=4 --scale huey=2




