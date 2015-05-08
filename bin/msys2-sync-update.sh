
echo "Synchronizing msys2 package databases..."
pacman --noconfirm -Sy
echo "Package synchronization finished."

echo "Updating core msys2 packages..."
pacman -S --noconfirm --needed --force bash
pacman -S --noconfirm --needed --force pacman
pacman -S --noconfirm --needed --force pacman-mirrors
pacman -S --noconfirm --needed --force msys2-runtime
echo "Core packages updated..."