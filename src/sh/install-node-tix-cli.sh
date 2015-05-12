#!/bin/bash

echo prefix = ${HOME:2}/local/bin > ~/.npmrc
curl -L https://www.npmjs.org/install.sh | sh
npm install -g tix-cli && tix -ix
