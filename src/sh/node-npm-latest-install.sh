echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashrc
. ~/.bashrc

mkdir ~/local
mkdir ~/src
mkdir ~/src/node-latest-install && cd ~/src/node-latest-install

curl -L http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
./configure --prefix=~/local
make install # ok, fine, this step probably takes more than 30 seconds...
curl -L https://www.npmjs.org/install.sh | sh