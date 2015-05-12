echo prefix = ~/local > ~/.npmrc
curl -L https://www.npmjs.org/install.sh | sh
npm install -g tix-cli && tix -ix
