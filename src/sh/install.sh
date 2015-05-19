#!/bin/bash
#
# This file takes over after the powershell install and finishes the job using unix

INSTALL_ROOT="${HOME}"
NPMRC_PATH="${HOME}/.npmrc"
CSDK_PATH="${INSTALL_ROOT}/src/bin/wdexpress_full.exe"
NODE_PATH="${LOCAL_BIN_ROOT}/node.exe"
LOCAL_BIN_ROOT="${INSTALL_ROOT}/local/bin"

if [ ! -e $NPMRC_PATH ]; then
  echo "--Creating new ~/.npmrc--"
  echo prefix = ${LOCAL_BIN_ROOT:2} > $NPMRC_PATH
fi

if [ ! -e $CSDK_PATH ]; then
  echo "--Installing Visual Studio Express Visual C++ SDK"
  curl -L "http://go.microsoft.com/?linkid=9816758" > $CSDK_PATH
  pushd "${INSTALL_ROOT}/src/bin"
  cmd.exe /c wdexpress_full.exe
  popd
fi

if [ ! -e $NODE_PATH ]; then
  echo "--Installing 32-bit node.exe--"
  curl -L http://nodejs.org/dist/v0.12.3/node.exe > $NODE_PATH
fi

echo "--Installing NPM--"
curl -L https://www.npmjs.org/install.sh | sh

echo "--Installing tix-cli globally--"
npm install -g tix-cli

echo "--Running tix-cli with optional applications and extended mode--"
tix -ox