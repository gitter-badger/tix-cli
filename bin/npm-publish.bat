pushd ..\
npm version patch && npm publish && git push origin master
popd