#!/bin/sh -ex
echo "Executing tix-cli in ~/tixinc/tix-cli/..."
node ~/tixinc/tix-cli/tix-cli.js || mkdir -p ~/tixinc/tix-cli && curl https://raw.githubusercontent.com/TixInc/tix-cli/master/tix-cli.js > ~/tixinc/tix-cli/tix-cli.js && node ~/tixinc/tix-cli/tix-cli.js