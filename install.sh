#!/bin/bash
# Copyright (c) 2024 Berk Kirtay

# Colors:
RED='\033[0;31m'

START_TIME=$(date +%s)

PACKAGE_SYNC_SCRIPT="./assets/packages/sync_packages.sh"
PKGLIST="./assets/packages/pkglist.txt"
PKGLIST_AUR="./assets/packages/pkglist_aur.txt"

echo -e "${RED}1. Install script is starting.. Start time ==> $START_TIME"

echo -e "${RED}2. Clearing the recent pacman cache."
sudo paccache -rk3

sudo pacman -Syu
echo -e "${RED}3. System update is successful".

sudo sh $PACKAGE_SYNC_SCRIPT
echo -e "${RED}4. System repositories are successfully synchronized."

# Install required packages from both repository and AUR:
pkglist_number=$(wc -l $PKGLIST)
aur_pkglist_number=$(wc -l $PKGLIST_AUR)

echo -e "${RED}5. Following repository packages will be installed ==> ${pkglist_number}"
sudo pacman -S --needed - < $PKGLIST

echo -e "${RED}6. Following AUR packages will be installed ==> ${aur_pkglist_number}"
mkdir -p aur_repositories
cd aur_repositories
cat "../$PKGLIST_AUR" | while read line || [[ -n $line ]];
do
    package_name="https://aur.archlinux.org/${line}.git"
    git clone $package_name && cd "./$line" && makepkg -si && cd ..
done
cd ..
echo -e "${RED}7. Default shell is changed to zsh."
sudo chsh -s /usr/bin/zsh


echo -e "${RED}8. Moving the system configs to the home directory."
cd system 
cp -Rp . ../
cd ..

echo -e "${RED}9. The script completed execution in $(date -d@$(($(date +%s) - START_TIME)) -u +%H\ hours\ %M\ min\ %S\ sec)"


