
echo "Synchronizing msys2 package databases..."
pacman -Sy --noconfirm
echo "Package synchronization finished."

echo "Updating core msys2 packages..."
pacman -S --noconfirm --needed bash pacman pacman-mirrors msys2-runtime
#pacman -S --needed pacman
#pacman -S --needed pacman-mirrors
#pacman -S --needed msys2-runtime
echo "Core packages updated..."
