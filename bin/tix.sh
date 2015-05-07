echo "Executing tix-cli..."
node ~/TixInc/TixCli/tix-cli || curl https://raw.githubusercontent.com/TixInc/TixCli/master/tix-cli.js > tix-cli.js && node tix-cli
