#!/bin/bash
#
# This file takes over after the powershell install and finishes the job using unix

NPMRC_PATH="${HOME}/.npmrc"
INSTALL_ROOT="${HOME}"
INSTALL_LOG_PATH="${INSTALL_ROOT}/tix-install.log"
LOCAL_BIN_ROOT="${INSTALL_ROOT}/local/bin"
SRC_BIN_ROOT="${INSTALL_ROOT}/src/bin"
CSDK_PATH="${SRC_BIN_ROOT}/wdexpress_full.exe"
NODE_PATH="${LOCAL_BIN_ROOT}/node.exe"
MSVS_VERSION=2012

if [ ! -e $NPMRC_PATH ]; then
  echo "--Creating new ~/.npmrc--" | tee $INSTALL_LOG_PATH
  echo prefix = ${LOCAL_BIN_ROOT:2} > $NPMRC_PATH
fi

if [ ! -e $CSDK_PATH ]; then
  echo "--Installing Visual Studio 2013 Community--" | tee $INSTALL_LOG_PATH
  echo "--You must install the Visual Studio C++ Tools for Windows Desktop for this to work--" | tee $INSTALL_LOG_PATH
  curl -L "http://go.microsoft.com/?linkid=9816758" > $CSDK_PATH
  pushd "${SRC_BIN_ROOT}"
  cmd.exe /c wdexpress_full.exe 2>&1 | tee $INSTALL_LOG_PATH
  popd
  echo -n "Visual studio tools have finished installing.  Register your version of Visual Studio and hit enter..." | tee $INSTALL_LOG_PATH
  read
fi

if ! hash node 2>/dev/null; then
  echo "--Installing 32-bit node.exe--" | tee $INSTALL_LOG_PATH
  curl -L http://nodejs.org/dist/v0.12.3/node.exe > $NODE_PATH
fi

if ! hash npm 2>/dev/null; then
  echo "--Installing NPM--" | tee $INSTALL_LOG_PATH
  curl -L https://www.npmjs.org/install.sh | sh
fi

echo "--Setting VS tools version to ${MSVS_VERSION}" | tee $INSTALL_LOG_PATH
npm config set msvs_version ${MSVS_VERSION} --global 2>&1 | tee $INSTALL_LOG_PATH

echo "--Installing Global Node Tools--" | tee $INSTALL_LOG_PATH
if ! hash rimraf 2>/dev/null; then
  echo "--**installing rimraf**--" | tee $INSTALL_LOG_PATH
  echo "--**short for 'rm -rf' (remove recursive/force)**--" | tee $INSTALL_LOG_PATH
  npm install -g rimraf 2>&1 >> $INSTALL_LOG_PATH
fi
if ! hash nodemon 2>/dev/null; then
  echo "--**installing nodemon**--" | tee $INSTALL_LOG_PATH
  echo "--**runs node.js and watches server-side files for updates to trigger process reload**--" | tee $INSTALL_LOG_PATH
  npm install -g nodemon 2>&1 >> $INSTALL_LOG_PATH
fi
if ! hash nodemon 2>/dev/null; then
  echo "--**installing forever**--" | tee $INSTALL_LOG_PATH
  echo "--**runs node.js in a production setting, ensuring the process never goes down**--" | tee $INSTALL_LOG_PATH
  npm install -g forever 2>&1 >> $INSTALL_LOG_PATH
fi
#if ! hash node-gyp 2>/dev/null; then
  #echo "--**node-gyp**--" | tee $INSTALL_LOG_PATH
  #npm install -g node-gyp 2>&1 >> $INSTALL_LOG_PATH
#fi

### Change these back to npm install -g automattic/socket.io when issues with socket.io versions have been fixed on npm
#echo "--**socket.io**--" | tee $INSTALL_LOG_PATH
#npm install -g automattic/socket.io 2>&1 >> $INSTALL_LOG_PATH
#echo "--**socket.io-client**--" | tee $INSTALL_LOG_PATH
#npm install -g automattic/socket.io-client 2>&1 >> $INSTALL_LOG_PATH
#echo "--**engine.io-client**--" | tee $INSTALL_LOG_PATH
#npm install -g automattic/engine.io 2>&1 >> $INSTALL_LOG_PATH

#echo "--**ws**--" | tee $INSTALL_LOG_PATH
#npm install -g ws 2>&1 >> $INSTALL_LOG_PATH

if ! hash browser-sync 2>/dev/null; then
  echo "--**browser-sync**--" | tee $INSTALL_LOG_PATH
  npm install -g browser-sync 2>&1 >> $INSTALL_LOG_PATH
  echo "--**installing ws@latest to fix current npm issues with browser-sync**--" | tee $INSTALL_LOG_PATH
  echo "--**see https://github.com/Automattic/socket.io/issues/2057**--" | tee $INSTALL_LOG_PATH
  browser_sync_engine_io_modules_root="${LOCAL_BIN_ROOT}/node_modules/browser-sync/node_modules/socket.io/node_modules/engine.io/node_modules"
  browser_sync_engine_io_client_modules_root="${LOCAL_BIN_ROOT}/node_modules/browser-sync/node_modules/socket.io/node_modules/socket.io-client/node_modules/engine.io-client"
  mkdir -p $browser_sync_engine_io_modules_root
  mkdir -p $browser_sync_engine_io_client_modules_root
  pushd $browser_sync_engine_io_modules_root
    npm install ws@latest 2>&1 >> $INSTALL_LOG_PATH
  popd
  pushd $browser_sync_engine_io_client_modules_root
    npm install ws@latest 2>&1 >> $INSTALL_LOG_PATH
  popd
fi

if ! hash gulp 2>/dev/null; then
  echo "--**gulp**--" | tee $INSTALL_LOG_PATH
  npm install -g gulp 2>&1 >> $INSTALL_LOG_PATH
fi

echo "--Installing tix-cli globally--" | tee $INSTALL_LOG_PATH
npm install -g tix-cli 2>&1 >> $INSTALL_LOG_PATH

echo "--Running tix-cli with optional applications and extended mode--" | tee $INSTAL_LOG_PATH
tix -ox