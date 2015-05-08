
echo "Synchronizing msys2 package databases..."
pacman --noconfirm -Sy
echo "Package synchronization finished."

echo "Updating core msys2 packages..."
pacman -S --noconfirm --needed bash
pacman -S --noconfirm --needed pacman
pacman -S --noconfirm --needed pacman-mirrors
pacman -S --noconfirm --needed msys2-runtime
echo "Core packages updated..."