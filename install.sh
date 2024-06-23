#!/bin/bash
# Copyright (c) 2024 Berk Kirtay

RED='\033[0;31m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m' 
PROGRESS_BAR='####################'
PACKAGE_SYNC_SCRIPT="./assets/packages/sync_packages.sh"
PKGLIST="./assets/packages/pkglist.txt"
PKGLIST_AUR="./assets/packages/pkglist_aur.txt"
START_TIME=$(date +%s)
progress_step=0

function print_progress_info() {
	sleep 1
	((progress_step++))
	local log="$1"
	local step=$(($progress_step*2))
	local remaining_step=$((20 - $step))
	tput clear
	echo -e "\r${YELLOW}[${PROGRESS_BAR:0:$step}$(printf "%${remaining_step}s")] %$((progress_step*10)) ${RED}$log${NO_COLOR}\n"
}

print_progress_info "Install script is starting."

print_progress_info "Clearing the recent pacman cache."
sudo paccache -rk3

print_progress_info "System update is progressing."
sudo pacman -Syu

sudo sh $PACKAGE_SYNC_SCRIPT
print_progress_info "System repositories are successfully synchronized."

# Install required packages from both repository and AUR:
pkglist_number=$(wc -l $PKGLIST)
aur_pkglist_number=$(wc -l $PKGLIST_AUR)

print_progress_info "Following repository packages will be installed ==> ${pkglist_number}"
sudo pacman -S --noconfirm --needed - < $PKGLIST

print_progress_info "Following AUR packages will be installed ==> ${aur_pkglist_number}"
mkdir -p aur_repositories
cd aur_repositories
cat "../$PKGLIST_AUR" | while read line || [[ -n $line ]];
do
  package_name="https://aur.archlinux.org/${line}.git"
	git clone $package_name 
  cd $line 
  sudo chmod a+rwx .    
  makepkg -si --nocheck 
  cd ..
done
cd ..

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

print_progress_info "Default shell is changed to zsh and oh-my-zsh is installed."
sudo chsh -s /usr/bin/zsh

print_progress_info "Moving the system configs to the home directory."
cd system 
cp -Rp . ../
cd ..

print_progress_info "Generating default locale settings."
sudo echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
sudo echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/locale.conf
sudo echo "LC_CTYPE=en_US.UTF-8" | sudo tee -a /etc/locale.conf
sudo locale-gen

print_progress_info "The script completed execution in $(date -d@$(($(date +%s) - START_TIME)) -u +%H\ hours\ %M\ min\ %S\ sec)."