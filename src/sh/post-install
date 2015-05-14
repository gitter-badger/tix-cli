#!/bin/bash
#
# This file takes over after the powershell install and finishes the job using unix

INSTALL_ROOT=$HOME

echo prefix = ${INSTALL_ROOT:2}/local/bin > $INSTALL_ROOT/.npmrc
curl -L https://www.npmjs.org/install.sh | sh

mkdir -p $INSTALL_ROOT/local/bin
curl http://beyondgrep.com/ack-2.14-single-file > $INSTALL_ROOT/local/bin/ack
npm install -g tix-cli && tix -ix
