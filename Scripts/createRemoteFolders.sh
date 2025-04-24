#! /bin/bash

mkdir ~/RemoteDrives
mkdir ~/RemoteDrives/BudliGeGe
systemctl --user enable --now rclonemount@BudliGeGe
mkdir ~/RemoteDrives/BudliFlocke
systemctl --user enable --now rclonemount@BudliFlocke
mkdir ~/RemoteDrives/UNIOneDrive
systemctl --user enable --now rclonemount@UNIOneDrive
mkdir ~/RemoteDrives/BirgerOneDrive
systemctl --user enable --now rclonemount@BirgerOneDrive
