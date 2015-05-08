
echo "Synchronizing msys2 package databases..."
pacman --noconfirm -Sy
echo "Package synchronization finished."

echo "Updating core msys2 packages..."
yes | pacman -S --needed bash pacman pacman-mirrors msys2-runtime
#pacman -S --needed pacman
#pacman -S --needed pacman-mirrors
#pacman -S --needed msys2-runtime
echo "Core packages updated..."
