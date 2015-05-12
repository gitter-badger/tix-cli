echo "Ensuring directory"
mkdir -p ~/tixinc/tix-cli
echo "Downloading tix-cli"
curl https://raw.githubusercontent.com/TixInc/tix-cli/master/tix-cli.js > ~/tixinc/tix-cli/tix-cli.js
echo "Executing tix-cli"
node ~/tixinc/tix-cli/tix-cli.js