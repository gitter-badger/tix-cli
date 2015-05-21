#!/bin/bash
#
# This file takes over after the powershell install and finishes the job using unix

NPMRC_PATH="${HOME}/.npmrc"
INSTALL_ROOT="${HOME}"
INSTALL_LOG_PATH="${INSTALL_ROOT}/tix-install.log"
LOCAL_ROOT="${INSTALL_ROOT}/local"
LOCAL_BIN_ROOT="${LOCAL_ROOT}/bin"
LOCAL_CONFIG_ROOT="${LOCAL_ROOT}/config"
SRC_BIN_ROOT="${INSTALL_ROOT}/src/bin"
CSDK_ROOT="${SRC_BIN_ROOT}/VS2013_4_CE_ENU"
NUGET_PATH="${LOCAL_BIN_ROOT}/nuget.exe"
NODE_PATH="${LOCAL_BIN_ROOT}/node.exe"
RES_CONFIG_PATH="${LOCAL_CONFIG_ROOT}/res.config"
VS2012_WDX_7Z_PATH="${SRC_BIN_ROOT}/vs2012_wdx.7z"
VS2012_WDX_INSTALL_ROOT="${SRC_BIN_ROOT}/vs2012_wdx"
VS2012_WDX_EXE_PATH="${DEVENVDIR}/WDExpress.exe"
MSVS_VERSION=2012

if [ ! -e "$NPMRC_PATH" ]; then
  echo "--Creating new ~/.npmrc--" | tee $INSTALL_LOG_PATH
  echo prefix = ${LOCAL_BIN_ROOT:2} > $NPMRC_PATH
  echo "//registry.npmjs.org/:_authToken=aca97731-9f24-46fa-a0bb-7f547b937342" >> $NPMRC_PATH
fi


#if [ ! -f "$VS2012_WDX_EXE_PATH" ]; then
#  mkdir -p $SRC_BIN_ROOT
#  pushd $SRC_BIN_ROOT
#    echo "--Downloading VS2012 express tools for windows desktop...--"
#    if [ ! -f "$VS2012_WDX_7Z_PATH" ]; then
#      curl -L https://s3-us-west-2.amazonaws.com/tixinc/vs2012_wdx/vs2012_wdx.7z >vs2012_wdx.7z
#    fi
#    if [ ! -d "$VS2012_WDX_INSTALL_ROOT" ]; then
#      mkdir -p $VS2012_WDX_INSTALL_ROOT
#      7za x vs2012_wdx.7z -o"$VS2012_WDX"
#    fi
#    pushd $VS2012_WDX_INSTALL_ROOT
#      echo "--Installing VS2012 tools for windows desktop...--"
#      cmd.exe /c wdexpress_full.exe
#      echo -n "--Hit enter when finished with install / registration--"
#      read
#    popd
#  popd
#fi

### choco install of the VS 2012 for windows desktop does not seem to work
#echo "--Installing Visual Studio Express 2012 for Windows Desktop 11.0--"
#choco install visualstudio2012wdx --yes --force >> $INSTALL_LOG_PATH

### Optional step for setting up VS 2013 community
if [ -d "$CSDK_ROOT" ]; then
  echo "--Installing Visual Studio 2013 Community--" | tee $INSTALL_LOG_PATH
  echo "--You must install the Visual Studio MFC C++ Tools for this to work--" | tee $INSTALL_LOG_PATH
  ### Web installer
  ###curl -L "http://go.microsoft.com/?linkid=9816758" > $CSDK_PATH
  pushd "${CSDK_ROOT}"
  cmd.exe /c vs_community.exe 2>&1 | tee $INSTALL_LOG_PATH
  popd
  echo -n "Visual studio tools have finished installing.  Register your version of Visual Studio and hit enter..." | tee $INSTALL_LOG_PATH
  read
fi

### Set window resolution information
if hash powershell 2>/dev/null; then
  echo "--Getting Resolution Info--"
  mkdir -p $LOCAL_CONFIG_ROOT
  powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.Screen]::AllScreens" > $RES_CONFIG_PATH
fi

if [ ! -e "$NUGET_PATH" ]; then
  curl -L "https://nuget.org/nuget.exe" > $NUGET_PATH
fi

if ! hash node 2>/dev/null; then
  echo "--Installing 32-bit node.exe--" | tee $INSTALL_LOG_PATH
  curl -L http://nodejs.org/dist/v0.12.3/node.exe > $NODE_PATH
fi

### Force UAC popup
PowerShell -Command "Start-Process node.exe -Verb RunAs"

if ! hash npm 2>/dev/null; then
  echo "--Installing NPM--" | tee $INSTALL_LOG_PATH
  curl -L https://www.npmjs.org/install.sh | sh >> $INSTALL_LOG_PATH

  echo "--Setting VS tools version to ${MSVS_VERSION}" | tee $INSTALL_LOG_PATH
  npm config set msvs_version ${MSVS_VERSION} --global 2>&1 | tee $INSTALL_LOG_PATH
fi

echo "--Installing Global Node Tools--" | tee $INSTALL_LOG_PATH
if ! hash rimraf 2>/dev/null; then
  echo "--**installing rimraf**--" | tee $INSTALL_LOG_PATH
  echo "--**short for 'rm -rf' (remove recursive/force)**--" | tee $INSTALL_LOG_PATH
  npm install -g rimraf >> $INSTALL_LOG_PATH
fi
if ! hash nodemon 2>/dev/null; then
  echo "--**installing nodemon**--" | tee $INSTALL_LOG_PATH
  echo "--**runs node.js and watches server-side files for updates to trigger process reload**--" | tee $INSTALL_LOG_PATH
  npm install -g nodemon >> $INSTALL_LOG_PATH
fi
if ! hash nodemon 2>/dev/null; then
  echo "--**installing forever**--" | tee $INSTALL_LOG_PATH
  echo "--**runs node.js in a production setting, ensuring the process never goes down**--" | tee $INSTALL_LOG_PATH
  npm install -g forever >> $INSTALL_LOG_PATH
fi
if ! hash node-gyp 2>/dev/null; then
  echo "--**node-gyp**--" | tee $INSTALL_LOG_PATH
  npm install -g node-gyp >> $INSTALL_LOG_PATH
fi

if ! hash browser-sync 2>/dev/null; then
  echo "--**browser-sync**--" | tee $INSTALL_LOG_PATH
  npm install -g browser-sync &>/dev/null
  echo "--**installing ws@latest to fix current npm issues with browser-sync**--" | tee $INSTALL_LOG_PATH
  echo "--**see https://github.com/Automattic/socket.io/issues/2057**--" | tee $INSTALL_LOG_PATH
  browser_sync_engine_io_modules_root="${LOCAL_BIN_ROOT}/node_modules/browser-sync/node_modules/socket.io/node_modules/engine.io/node_modules"
  browser_sync_engine_io_client_modules_root="${LOCAL_BIN_ROOT}/node_modules/browser-sync/node_modules/socket.io/node_modules/socket.io-client/node_modules/engine.io-client"
  mkdir -p $browser_sync_engine_io_modules_root
  mkdir -p $browser_sync_engine_io_client_modules_root
  pushd $browser_sync_engine_io_modules_root
    npm install ws@latest &>/dev/null
  popd
  pushd $browser_sync_engine_io_client_modules_root
    npm install ws@latest &>/dev/null
  popd
fi

if ! hash gulp 2>/dev/null; then
  echo "--**gulp**--" | tee $INSTALL_LOG_PATH
  npm install -g gulp >> $INSTALL_LOG_PATH
fi

echo "--Installing tix-cli globally--" | tee $INSTALL_LOG_PATH
npm install -g tix-cli >> $INSTALL_LOG_PATH

echo "--Running tix-cli with optional applications and extended mode and no-run--" | tee $INSTALL_LOG_PATH
tix -oxn

echo "--Full dev clone--"
clone-all-dev

#echo "--Installing custom fonts--"
#install-fonts >> $INSTALL_LOG_PATH

echo "--Run JS project in debug mode--"
debug-js
