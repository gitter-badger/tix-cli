#!/bin/bash
#
# This file takes over after the powershell install and finishes the job using unix

INSTALL_ROOT="${HOME}"
NPMRC_PATH="${HOME}/.npmrc"
LOCAL_BIN_ROOT="${INSTALL_ROOT}/local/bin"

echo "--Creating new ~/.npmrc--"
echo prefix = ${LOCAL_BIN_ROOT:2} > $NPMRC_PATH

echo "--Installing 32-bit node.exe--"
#curl -L http://nodejs.org/dist/v0.12.3/node.exe > "${LOCAL_BIN_ROOT}/node.exe"

echo "--Installing NPM--"
curl -L https://www.npmjs.org/install.sh | sh

echo "--Installing tix-cli globally--"
npm install -g tix-cli

echo "--Running tix-cli with optional applications and extended mode--"
tix -ox