pushd ..\ && git add . && git commit -am "updates to tix-cli-src" && npm version patch && npm publish && git push origin master && popd
