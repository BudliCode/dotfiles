# Arch Linux Installation and Configuration

## Set keyboard layout

Load german keyboard layout. Use "?" on a german keyboard to type "-"
```sh
loadkeys de-latin1
```

##  WiFi

Enter iwctl
```
iwctl
```

Check the name and adapter of your wireless devices. It might be different than wlan0.
```
device list
```

If needed power on the adapter.
```
adapter <adapter> set-property Powered on
```

Scan for available Networks. This command has no verbose output
```
station wlan0 scan
```

Show available networks
```
station wlan0 get-networks
```

Connect to network
```
station wlan0 connect <SSID>
```

## SSH

Enable sshd (should be by default)
```sh
systemctl enable sshd
```

Set password for current user
```sh
passwd
```

Show device IP address
```sh
ip addr
```

Remotely login with this command:
```sh
ssh root@<sddr>
```

## Partitioning

Get names of the blocks
```sh
lsblk
```

Enter gdisk
```sh
gdisk /dev/nvme0n1
```
Inside of gdisk use `x` for advanced options and `z` to to whipe the current partition table.

Enter gdisk again, and create new partitions using `n` command.

| partition | first sector | last sector | code | use  |
|-----------|--------------|-------------|------|------|
|1          | default      | +512M       | ef00 | EFI  |
|2          | default      | +4G         | ef02 | boot |
|3          | default      | default     | 8309 | Luks |


## Encryption

Load the encryption modules to be save.
```sh
modprobe dm-crypt
```
```sh
modprobe dm-mod
```

Setting up encryption on the luks lvm partition. Enter your password, and keep it save!!
```sh
cryptsetup luksFormat -v -s 512 -h sha512 /dev/nvme0n1p3
```

Mount the dive
```sh
cryptsetup open /dev/nvme0n1p3 luks_lvm
```

## Volume setup

Create the volume and volume group
```sh
pvcreate /dev/mapper/luks_lvm
```sh
vgcreate arch /dev/mapper/luks_lvm
```

Create swap volume. Size should be RAM size + 2G
```sh
lvcreate -n swap -L 18G arch
```

Root volume
```sh
lvcreate -n root -L 128G arch
```

Remaining space for home partition
```sh
lvcreate -n home -l +100%FREE arch
```

## Filesystems

FAT32 on EFI partition
```sh
mkfs.fat -F32 /dev/nvme0n1p1
```

EXT4 on Boot partition
```sh
mkfs.ext4 /dev/nvme0n1p2
```

BTRFS on root
```sh
mkfs.btrfs -L root /dev/mapper/arch-root
```

BTRFS on home
```sh
mkfs.btrfs -L root /dev/mapper/arch-home
```

Setup swap
```sh
mkswap /dev/mapper/arch-swap
```

## Mounting

Mount swap
```sh
swapon /dev/mapper/arch-swap
```
```sh
swapon -a
```

Mount root
```sh
mount /dev/mapper/arch-root /mnt
```

Create home and boot directory in root
```sh
mkdir -p /mnt/{home,boot}
```

Mount boot
```sh
mount /dev/nvme0n1p2 /mnt/boot
```

Mount home
```sh
mount /dev/mapper/arch-home /mnt/home
```

Create efi directory
```sh
mkdir /mnt/boot/efi
```

Mount EFI
```sh
mount /dev/nvme0n1p1 /mnt/boot/efi
```

## Install arch

```sh
pacstrap -K /mnt base base-devel Linux Linux-Firmware
```

Load the file table
```sh
$genfstab -U -p /mnt > /mnt/etc/fstab
```

chroot into installation
```sh
$arch-chroot /mnt /bin/bash
```

## Configuration

### Text editor

Install bash-completion for qualtity of life and a terminal text editor of choice.
```sh
pacman -S bash-completion nano neovim
```

### Decrypting volumes

Add `encrypt` and `lvm2` HOOKS
```sh
nvim /etc/mkinitcpio.conf
```
```
HOOKS=(... block encrypt lvm2 filesystem ...)
```

Install lvm2
```sh
packman -S lvm2
```

### Bootloader

Install grub and efibootmgr
```sh
pcaman -S grub efibootmgr
```

Setup grub on efi partition
```sh
grub-install --efi-directory=/boot/efi
```

Obtain your lvm partition device UUID and copy them to your clipboard.
```sh
get uuid: blkid /dev/nvme0n1p3
```

Add the following kernel parameters to grub.
```sh
nvim /etc/default/grub
```
```sh
add to variables: root=/dev/mapper/arch-root cryptdevice=UUID=<uuid>:luks_lvm 
```

### Keyfile

```sh
mkdir /secure
```

Create root keyfile
```sh
dd if=/dev/random of=/secure/root_keyfile.bin bs=512 count=8
```

Change permissions
```sh
chmod 000 /secure/root_keyfile.bin
```

Also smart to change permissions on these
```sh
chmod 600 /boot/initramfs-linnux*
```

Add keyfile to partition
```sh
cryptsetup luksAddKey /dev/nvme0n1p3 /secure/root_keyfile.bin
```

Add keyfile to mkinitcpio.conf
```sh
nvim /etc/mkinitcpio.conf
```
```
FILES=(/secure/root_keyfile.bin)
```
reload linux
```sh
mkinitcpio -p linux
```

## Grub

Create grub config
```sh
grub-mkconfig -o /boot/grub/grub.cfg
```
```sh
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```

## system configuration

### Keyboard

Save keyboard config to file
```sh
echo "KEYMAP=de-latin1" > /etc/vconsole.conf
```

### Time

#### Timezone

```sh
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
```
```sh
hwclock --systohc
```

#### NTP

Add NTP servers:
```sh
nvim /etc/systemd/timesyncd.conf
```
```
[Time]
NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org 
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org
```

Enable timesyncd
```sh
systemctl enable systemd-timesyncd.service
```

### Locale

Uncomment locales (de_DE.UTF-8 and en_US.UTF-8)
```sh
    nvim /etc/locale.gen
```
```
de_DE.UTF-8 UTF-8
en_US.UTF-8 UTF-8
```
```sh
locale-gen
```

```sh
nvim /etc/locale.conf
```
```
LANG=en_US.UTF-8
LANGUAGE=en_US:en:C:de_DE:de
LC_COLLATE=C
LC_TIME=de_DE.UTF-8
```

### Hostname

```sh
echo "name" > /etc/hostname
```

Enable multilib, color and parallelDownload in /etc/pacman.conf
```sh
nvim /etc/pacman.conf
```
```
Color
ParallelDownloads = 5
...
[multilib]
Include = /etc/pacman.d/mirrorlist
```
```sh
    $pacman -Sy
```

### Users

Install zsh if you want your user to use it instead of Bash
```sh
pacman -S zsh
```

Set root password
```sh
passwd
```

Add new user
```sh
useradd -m -g users -G wheel,storage,power -s /bin/zsh user
```

Set pasword for user
```sh
passwd user
```

Add the wheel group to sudoers by uncommenting the line
```sh
EDITOR=nvim visudo
```
```
%wheel ALL=(ALL:ALL) ALL
```

### Network Connectivity

```sh
pacmann -S networkmanager
```
```sh
systemctl enable NetworkManager.service
```

### CPU micro-code
For intel:
```sh
pacman -S intel-ucode
```

For AMD:
```sh
pacman -S amd-ucode
```

Make grub.cfg
```sh
grub-mkconfig -o /boot/grub/grub.cfg
```
```sh
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```

## Reboot
```
    $exit
```
```
    $unmount -R /mnt
```
```
    $reboot
```

# Past Install

## Connect to WiFi

```sh
nmcli device wifi connect Zwerg password [password]
```

## Default directorys

Create all default XDG folder
```sh
sudo pacman -S xdg-uuser-dirs
```
```sh
xdg-user-dirs-updpate
```

Create folder for self installed programs
```sh
mkdir ~/Programs
```

## Yay

Install git to clone the repo
```sh
sudo pacman -S git
```

```sh
git clone https://aur.archlinux.org/yay.git  ~/Programs
```sh
cd ~/Programs
```sh
makepkg -si
```

## OpenSSH

```sh
yay -S openssh
```
```sh
$mkdir ~/.ssh
```
```sh
echo "AddKeysToAgent yes" > ~/.ssh/config
```
```sh
$systemctl --user enable --now ssh-agent.service
```
```sh
$ssh-keygen -C "comment"
```
TODO: setup ssh to remotely ssh into the system

## Power management

```sh
yay -S tlp
```
```sh
sudo systemctl enable --now tlp
```
```sh
sudo systemctl mask --now systemd-rfkill.service
```
```sh
sudo systemctl mask --now systemd-rfkill.socket
```

# Packages to install:
intel GPU:
    mesa
    lib32-mesa
    vulkan-intel
    lib32-vulkan-intel
    intel-gpu-tools
    libva-utils
    intel-media-driver

pipewire-audio:
    pipewire
    lib32-pipewire
    pipewire-docs
    wireplumber
    pwvucontrol
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    lib32-pipewire-jack

fonts install:
    ttf-liberation
    ttf-ubuntu-font-family
    ttf-anonymous-pro
    ttf-dejavu
    ttf-bitstream-vera
    adobe-source-sans-pro-fonts
    noto-fonts
    noto-fonts-cjk
    ttf-hack-nerd

basic apps:
    man-db
    man-pages
    tldr
    vivaldi
    alacritty
    dolphin
    wget
    zip
    unzip
    ripgrep
    keepassxc
    libreoffice-still
    tar

WM Hyprland:
    hyprland
    wofi
    dunst
    pipewire
    wireplumber
    xdg-desktop-portal-hyprland
    polkit-kde-agent
    qt5-wayland
    qt6-wayland
    hyprlidle
    hyprlock
    hyprpaper
    brightnessctl
    waybar


TODOs:
ssh
rate mirrors
complete ssh-agent setup after shell
hyprpaper (wallpaper)
hypridle (idle manager)
workspace manager? hyprsome
HyprLS editor support für hyprland config
hyprlock
hyprcurser + einrichten
wofi
Clipboard manager
screensharing? https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580
xwaylandvideobridge
Discord (Webcord?)
WebApps (Teams...)
greetd/
terminal emulator: kitty
shell: zsh + tmux
cmd prompt: starship
file explorer: thunar (später ranger?)
dotfiles kopieren
sound alsa pipewire
vivaldi einrichten
power management
dotfiles manager suchen
grub theme
sddm einrichten
theme einrichten
waybar einrichten
OSD
network manager applet
usb mounting udiskie?
tab-replacement?
hyprland plugins?
firewall?
screenshots?
nvim zufriedenstellend einrichten/lernen
VMsu
