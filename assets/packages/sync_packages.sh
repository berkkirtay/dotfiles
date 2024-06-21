#!/bin/bash
# Copyright (c) 2024 Berk Kirtay

PKGLIST="./assets/packages/pkglist.txt"
PKGLIST_AUR="./assets/packages/pkglist_aur.txt"

# $1: file name
function sync_repository_packages () {
  local PKGLIST="$1"
  declare -A hashmap 
  # Add the old package names to the set:
  while IFS= read -r line || [[ -n $line ]]; 
  do
    hashmap["$line"]="val"
  done < <(cat $PKGLIST 2>/dev/null)
  # Add the new package names to the set by excluding duplicates:
  readarray -t list_of_packages < <(pacman -Qqen)
  for package in "${list_of_packages[@]}"; 
  do
    hashmap["$package"]="val"
  done
  dump_to_file "$PKGLIST" "${!hashmap[@]}"
}

# $1: file name
function sync_aur_packages () {
  local PKGLIST_AUR="$1"
  declare -A hashmap 
  while IFS= read -r line || [[ -n $line ]]; 
  do
    hashmap["$line"]="val"
  done < <(cat $PKGLIST_AUR 2>/dev/null)
  readarray -t list_of_packages < <(pacman -Qqem)
  for package in "${list_of_packages[@]}"; 
  do
    hashmap["$package"]="val"
  done
  dump_to_file "$PKGLIST_AUR" "${!hashmap[@]}"
}

# $1: output_file
# @: list of packages name
function dump_to_file () {
  local output_file="$1"
  shift
  local list=("$@")
  echo -n > $output_file
  for key in "${list[@]}"
  do
      echo $key >> $output_file
  done
}

sync_repository_packages $PKGLIST
sync_aur_packages $PKGLIST_AUR