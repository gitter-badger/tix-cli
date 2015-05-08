
echo "Synchronizing msys2 package databases..."
pacman --noconfirm -Sy
echo "Package synchronization finished."

echo "Updating core msys2 packages..."
pacman --noconfirm --needed -S bash pacman pacman-mirrors msys2-runtime
echo "Core packages updated..."