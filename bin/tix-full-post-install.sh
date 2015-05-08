echo "Updating remaining msys2 packages..."
pacman --noconfirm --force -Su
echo "Remaining packages updated."

echo "Installing git..."
pacman --noconfirm --force -S git
echo "git install finished."

echo "Running node and npm install script..."
curl https://raw.githubusercontent.com/TixInc/TixCli/master/node-npm-src-install.sh > ~/build/node-npm-src-install.sh && sh ~/build/node-npm-src-install.sh
echo "Node and npm install script finished."

echo "Running TixCli install script..."
curl https://raw.githubusercontent.com/TixInc/TixCli/master/tix-cli-install.sh > ~/build/tix-cli-install.sh && sh ~/build/tix-cli-install.sh
echo "TixCli install script finished."