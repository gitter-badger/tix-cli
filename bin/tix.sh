if [ ! -e ~/tixinc/tix-cli/tix-cli.js ]
  then
    echo "Installing..."
    mkdir -p ~/tixinc/tix-cli
    git archive --format=tar --remote=https://github.com/TixInc/tix-cli HEAD | tar xf -C ~/tixinc/tix-cli -

    #curl https://raw.githubusercontent.com/TixInc/tix-cli/master/tix-cli.js > ~/tixinc/tix-cli/tix-cli.js && node ~/tixinc/tix-cli/tix-cli.js
fi

echo "Executing tix-cli in ~/tixinc/tix-cli/..."
node ~/tixinc/tix-cli/tix-cli.js