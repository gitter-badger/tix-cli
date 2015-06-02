pushd ..\ && git add . && git commit -am "updates to tix-cli" && npm version patch && npm publish && git push origin master && popd
