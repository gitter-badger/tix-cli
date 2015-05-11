echo prefix = ~/local >> ~/.npmrc
curl https://www.npmjs.org/install.sh | sh
npm install -g tix-cli && tix -ix
