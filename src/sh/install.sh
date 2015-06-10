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
NPM_PATH="${LOCAL_BIN_ROOT}/npm.exe"
RES_CONFIG_PATH="${LOCAL_CONFIG_ROOT}/res.config"
VS2012_WDX_7Z_PATH="${SRC_BIN_ROOT}/vs2012_wdx.7z"
VS2012_WDX_INSTALL_ROOT="${SRC_BIN_ROOT}/vs2012_wdx"
VS2012_WDX_EXE_PATH="${DEVENVDIR}/WDExpress.exe"
MSVS_VERSION=2012


# Ensure paths exist
mkdir -p "${LOCAL_BIN_ROOT}"
mkdir -p "${LOCAL_CONFIG_ROOT}"

# Skipping this until tix has a readonly user with private repo access
#if [ ! -e "$NPMRC_PATH" ]; then
#  printf "--Creating new ~/.npmrc--" | tee $INSTALL_LOG_PATH
#  printf prefix = ${LOCAL_BIN_ROOT:2} > $NPMRC_PATH
#  printf "//registry.npmjs.org/:_authToken=aca97731-9f24-46fa-a0bb-7f547b937342" >> $NPMRC_PATH
#fi

# Set window resolution information
if hash powershell 2>/dev/null; then
  >&2 printf -- "- getting resolution info -"
  powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.Screen]::AllScreens" >$RES_CONFIG_PATH
fi

if [ ! -f "$NUGET_PATH" ] ; then
  >&2 printf -- "- installing nuget -"
  curl -L "https://nuget.org/nuget.exe" >"$NUGET_PATH"
fi

if [ ! -f "$NODE_PATH" ] ; then
  >&2 printf -- "- installing 32-bit node.exe -"
  curl -L http://nodejs.org/dist/latest/node.exe >"$NODE_PATH"
fi

if [ ! -f "$NPM_PATH" ] ; then
  >&2 printf -- "- installing npm -"
  curl -L https://www.npmjs.org/install.sh | sh >/dev/null
  >&2 printf -- "- setting vs tools version to ${MSVS_VERSION} -"
  npm config set msvs_version "${MSVS_VERSION}" --global
  >&2 printf -- "- setting npm to use bash shell when using npm explore command -"
  npm config set shell bash
fi

>&2 printf -- "- installing tix-cli globally -"
npm install -g tix-cli >/dev/null

>&2 printf -- "- running tix-cli with required and optional applications and no-run -"
tix -ioRclpdn

>&2 printf -- "- building latest release artifacts -"
release -l

>&2 printf -- "- running artifacts -"
run-artifacts