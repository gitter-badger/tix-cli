#!/bin/bash
#
# This file takes over after the powershell install and finishes the job using unix

INSTALL_ROOT="${HOME}"
NPMRC_PATH="${HOME}/.npmrc"
LOCAL_BIN_ROOT="${INSTALL_ROOT}/local/bin"

echo "--Creating new ~/.npmrc--"
echo prefix = ${LOCAL_BIN_ROOT:2} > $NPMRC_PATH

echo "--Instalilng NPM--"
curl -L https://www.npmjs.org/install.sh | sh

echo "--Installing tix-cli with optional applications and extended mode--"
npm install -g tix-cli && tix -ox