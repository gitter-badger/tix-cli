pushd ..\
git add . && git commit -am "updates to tix-cli-src" && git push origin master
npm version patch && npm publish
git push origin master
popd
