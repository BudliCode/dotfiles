# My Arch Linux Setup Guide

## Set keyboard layout

```sh
$ loadkeys de-latin1
```


connect to wifi
```
    $ iwctl
```

```
    $ device list
```

```
    $ adapter [adapter] set-property Powered on
```

```
    $ station [name] scan
```

```
    $ station [name] get-networks
```

```
    $ station [name] connect [SSID]
```

```
$ timedatectl
```

```
systemctl enable sshd
```

```
passwd
```

```
ip addr to see addr for ssh
```



```
 lsblk //zur übersicht
```
```
 gdisk /dev/drive //x + z zum löschen aller partitionen
n //für neue partition
   p1: EFI EF00 512M
   p2: boot EF02 4G
   p3: Luks 8309
```
```
 modprobe dm-crypt
```
```
 modprobe dm-mod
```
```
 cryptsetup luksFormat -v -s 512 -h sha512 /dev/nvme0n1p3 //passwort aufschreiben!!!
```
```
 cryptsetup open /dev/nvme0n1p3 luks_lvm
```
```
 vgcreate arch /dev/mapper/luks_lvm
```
```
 lvcreate -n swap -L 18G arch //RAM size + 2G
```
```
 lvcreate -n root -L 128G arch
```
```
 lvcreate -n home -l +100%FREE arch
```
```
 mkfs.fat -F32 /dev/nvme0n1p1
```
```
 mkfs.ext4 /dev/nvme0n1p2
```
```
 mkfs.btrfs -L root /dev/mapper/arch-root
```
```
 mkfs.btrfs -L root /dev/mapper/arch-home
```
```
 mkswap /dev/mapper/arch-swap
```
```
 swapon /dev/mapper/arch-swap
```
```
 swapon -a
```
```
 mount /dev/mapper/arch-root /mnt
```
```
 mkdir -p /mnt/{home,boot}
```
```
 mount /dev/nvme0n1p2 /mnt/boot
```
```
 mount /dev/mapper/arch-home /mnt/home
```
```
 mkdir /mnt/boot/efi
```
```
 mount /dev/nvme0n1p1 /mnt/boot/efi
```

installation
```
    $pacstrap -K /mnt base base-devel Linux Linux-Firmware
```


```
    $genfstab -U -p /mnt > /mnt/etc/fstab
```
```
    $arch-chroot /mnt /bin/bash
```

```
    install:
        bash-completion
        nano
        neovim
```

```
    nvim /etc/mkinitcpio.conf // add encrypt and lvm2 between block and filesystem to HOOKS
```
    HOOKS=(... block encrypt lvm2 filesystem ...)
```
```

    Packman -S lvm2
```

```
    install:
        grub
        efibootmgr
```
```
    $grub-install --efi-directory=/boot/efi
```


```
    get uuid: blkid /dev/nvme0n1p3
```
```
    nvim /etc/default/grub
```
```
    add to variables: root=/dev/mapper/arch-root cryptdevice=UUID=<uuid>:luks_lvm 
```

Keyfile
```
    mkdir /secure
```
```
    dd if=/dev/random of=/secure/root_keyfile.bin bs=512 count=8
```
```
    chmod 000 /secure/root_keyfile.bin
```
```
    chmod 600 /boot/initramfs-linnux*
```
```
    cryptsetup luksAddKey /dev/nvme0n1p3 /secure/root_keyfile.bin
```

```
    nvim /etc/mkinitcpio.conf
```
```
    FILES=(/secure/root_keyfile.bin)
```
```
    mkinitcpio -p linux
```

```
    $grub-mkconfig -o /boot/grub/grub.cfg
```
```
    $grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```




system configuration

```
    $echo "KEYMAP=de-latin1" > /etc/vconsole.conf
```

```
    $ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
```
```
    $hwclock --systohc
```

```
    nvim /etc/systemd/timesyncd.conf
```
        add NTP servers:
```
            [Time]
            NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org 
            FallbackNTP=0.pool.ntp.org 1.pool.ntp.org
```
```
    systemctl enable systemd-timesyncd.service
```

```
    uncomment locales in /etc/locale (de_DE.UTF-8 and en_US.UTF-8)
```
```
    $locale-gen
```
```
    nvim /etc/locale.conf
```
```
        LANG=en_US.UTF-8
        LANGUAGE=en_US:en:C:de_DE:de
        LC_COLLATE=C
        LC_TIME=de_DE.UTF-8
```

    $echo "name" > /etc/hostname

    enable multilib, color and parallelDownload in /etc/pacman.conf
    $pacman -Sy

    install zsh

    $passwd //sets root password
    $useradd -m -g users -G wheel,storage,power -s /bin/zsh birger
    $passwd birger
    $ export EDITOR=nvim
    $visudo 
        uncomment first %wheel

    install:
    #    iwd
        networkmanager
    $systemctl enable NetworkManager.service
    #$systemctl enable NetworkManager-dispatcher.service
    #$systemctl enable systemd-resolved.service
    #ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

    install intel/amd-ucode

    $grub-mkconfig -o /boot/grub/grub.cfg
    $grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg

    $exit
    $unmount -R /mnt
    $reboot
    
    nmcli device wifi connect Zwerg password [password]

    install: xdg-user-dirs
        $xdg-user-dirs-update

    install git
    install yay in ~/Programs/
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

    install:
        openssh
    $mkdir ~/.ssh
    echo "AddKeysToAgent yes" > ~/.ssh/config
    $systemctl --user enable --now ssh-agent.service
    $ssh-keygen -C "comment"

Power management:
    install:
        tlp
    #systemctl enable --now tlp
    #systemctl mask --now systemd-rfkill.service
    #systemctl mask --now systemd-rfkill.socket

         
intel GPU install:
    mesa
    lib32-mesa
    vulkan-intel
    lib32-vulkan-intel
    intel-gpu-tools
    libva-utils
    intel-media-driver

audio install:
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

basic apps install:
    man-db
    man-pages
    tldr
    # vivaldi
    alacritty
    # dolphin
    wget
    zip
    unzip
    ripgrep
    keepassxc
    libreoffice-still
    tar

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

WM Hyprland install:
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
