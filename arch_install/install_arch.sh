#!/bin/bash

###############################################################################
#                        Script d'Installation Automatisée                    #
#                                                                             #
#                        Auteur : K-Montasir                                  #
#                        Date   : 14/12/2024                                  #
#-----------------------------------------------------------------------------#
# Description :                                                               #
# Ce script automatise l'installation d'un système de base, incluant la       #
# configuration du réseau, la préparation des disques, l'installation du      #
# système de base, la configuration du système, et l'installation du          #
# bootloader (GRUB).                                                          #
#-----------------------------------------------------------------------------#
# Étapes réalisées par ce script :                                            #
# 1. Demande du mot de passe root.                                            #
# 2. Configuration du réseau (DHCP ou manuelle).                              #
# 3. Préparation des disques (effacement des partitions, création des         #
#    partitions EFI/Boot, Swap, Home, et Root).                               #
# 4. Installation du système de base (montage des partitions, installation    #
#    des paquets de base).                                                    #
# 5. Configuration du système (fuseau horaire, locale, hostname, clavier,     #
#    NetworkManager, mot de passe root).                                      #
# 6. Installation du bootloader (GRUB pour UEFI ou BIOS).                     #
# 7. Finalisation de l'installation (démontage des partitions, message de     #
#    fin).                                                                    #
#-----------------------------------------------------------------------------#
# Avertissements :                                                            #
# - Ce script doit être exécuté avec des privilèges administrateur.           #
# - Assurez-vous d'avoir bien configuré les variables dans le fichier         #
#   config.cfg.                                                               #
# - Modifiez les variables en début de script si nécessaire.                  #
# - Ce script est conçu pour un environnement basé sur Arch Linux et les      #
#   chemins peuvent nécessiter des ajustements pour d'autres systèmes ou      #
#   configurations.                                                           #
###############################################################################

# --- Charger la configuration ---
source ./config.cfg

# --- Fonctions d'installation ---

# 0. Demande du mot de passe root
prompt_root_password() {
  while true; do
    echo "Veuillez entrer le mot de passe root :"
    read -s -p "Mot de passe root : " root_password
    echo
    read -s -p "Confirmez le mot de passe root : " root_password_confirm
    echo

    if [ "$root_password" == "$root_password_confirm" ]; then
      echo "Le mot de passe root a été défini avec succès."
      break
    else
      echo "Les mots de passe ne correspondent pas. Veuillez réessayer."
    fi
  done
}

# 1. Configuration du réseau
configure_network() {
  echo "Configuration du réseau..."
  if [ "$USE_DHCP" = true ]; then
    echo "Utilisation de DHCP"
    systemctl start dhcpcd
  else
    echo "Configuration manuelle du réseau"
    ip addr add ${IP_ADDRESS}/${CIDR} dev $(ip link | grep 'state UP' | awk '{print $2}' | sed 's/://')
    ip route add default via $GATEWAY
    echo "nameserver $DNS" > /etc/resolv.conf
  fi
}

# 2. Préparation des disques
prepare_disks() {
  echo "Préparation des disques..."

  # Effacer les partitions existantes
  wipefs -a $DISK

  # Créer une table de partition en fonction du mode (gpt pour UEFI, msdos pour BIOS)
  if [ "$PARTITION_TABLE_TYPE" = "gpt" ]; then
    parted -s $DISK mklabel gpt
  else
    parted -s $DISK mklabel msdos
  fi

  # Création des partitions
  echo "Création des partitions en fonction de la configuration..."

  # Partition 1 : EFI (pour UEFI) ou Boot (pour BIOS)
  if [ "$BOOT_MODE" = "UEFI" ]; then
    parted -s $DISK mkpart primary fat32 1MiB ${PART1_SIZE}
    parted -s $DISK set 1 boot on
    mkfs.fat -F32 ${DISK}1
  else
    parted -s $DISK mkpart primary ext4 1MiB ${PART1_SIZE}
    mkfs.ext4 ${DISK}1
  fi

  # Partition 2 : Swap
  parted -s $DISK mkpart primary linux-swap ${PART1_SIZE} $((PART1_SIZE + PART2_SIZE))
  mkswap ${DISK}2
  swapon ${DISK}2

  # Partition 3 : Home
  parted -s $DISK mkpart primary ext4 $((PART1_SIZE + PART2_SIZE)) $((PART1_SIZE + PART2_SIZE + PART3_SIZE))
  mkfs.ext4 ${DISK}3

  # Partition 4 : Root
  parted -s $DISK mkpart primary ext4 $((PART1_SIZE + PART2_SIZE + PART3_SIZE)) 100%
  mkfs.ext4 ${DISK}4
}

# 3. Installation de base
install_base_system() {
  echo "Installation du système de base..."
  mount ${DISK}4 /mnt  # Monter la partition root
  if [ "$BOOT_MODE" = "UEFI" ]; then
    mkdir -p /mnt/boot/efi
    mount ${DISK}1 /mnt/boot/efi  # Monter la partition EFI
  else
    mount ${DISK}1 /mnt/boot  # Monter la partition boot
  fi
  pacstrap /mnt base linux linux-firmware
  genfstab -U /mnt >> /mnt/etc/fstab
}

# 4. Configuration du système
configure_system() {
  echo "Configuration du système..."
  arch-chroot /mnt /bin/bash <<EOF
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    echo "$LOCALE UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=$LOCALE" > /etc/locale.conf
    echo "$HOSTNAME" > /etc/hostname
    echo "127.0.0.1   localhost" >> /etc/hosts
    echo "::1         localhost" >> /etc/hosts
    echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts
    echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf  # Configuration du clavier en azerty
    pacman -S --noconfirm networkmanager
    systemctl enable NetworkManager

    # Configurer le mot de passe root
    echo "root:$root_password" | chpasswd
EOF
}

# 5. Installation de GRUB ou bootloader UEFI
install_bootloader() {
  echo "Installation du bootloader..."
  if [ "$BOOT_MODE" = "UEFI" ]; then
    arch-chroot /mnt /bin/bash <<EOF
      pacman -S --noconfirm grub efibootmgr
      grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
      grub-mkconfig -o /boot/grub/grub.cfg
EOF
  else
    arch-chroot /mnt /bin/bash <<EOF
      pacman -S --noconfirm grub
      grub-install --target=i386-pc $DISK
      grub-mkconfig -o /boot/grub/grub.cfg
EOF
  fi
}

# 6. Finalisation
finalize_install() {
  echo "Finalisation de l'installation..."
  umount -R /mnt
  echo "Installation terminée. Vous pouvez redémarrer."
}

# --- Exécution du script ---

prompt_root_password  # Étape 0 : Demande du mot de passe root
configure_network    # Étape 1 : Configuration du réseau
prepare_disks        # Étape 2 : Préparation des disques
install_base_system  # Étape 3 : Installation du système de base
configure_system     # Étape 4 : Configuration du système
install_bootloader   # Étape 5 : Installation du bootloader (GRUB)
finalize_install      # Étape 6 : Finalisation de l'installation
