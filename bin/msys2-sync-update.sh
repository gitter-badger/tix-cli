echo "Synchronizing msys2 package databases..."
pacman -Sy
echo "Package synchronization finished."

echo "Updating core msys2 packages..."
pacman --needed -S bash pacman pacman-mirrors msys2-runtime
echo "Core packages updated..."