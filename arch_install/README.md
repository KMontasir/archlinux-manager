# Installation Automatisée d'Arch Linux

Ce script permet d'installer et de configurer automatiquement Arch Linux avec des options personnalisables.

## Prérequis
- Un environnement live d'Arch Linux (ex. : USB bootable).
- Connexion Internet.
- Disque dur ou SSD pour l'installation.
- Un accès à la ligne de commande.

## Configuration
Avant d'exécuter le script, vous devez modifier le fichier de configuration `config.cfg` selon vos besoins. Voici les options disponibles :

1. **Réseau :**
   - `USE_DHCP` : `true` pour utiliser DHCP, `false` pour une configuration manuelle.
   - `IP_ADDRESS`, `CIDR`, `GATEWAY`, `DNS` : Utilisez ces variables si `USE_DHCP` est `false`.

2. **Disques :**
   - `DISK` : Chemin du disque principal (ex. : `/dev/sda`).
   - `PARTITION_TABLE_TYPE` : Type de table de partition (`gpt` ou `msdos` pour BIOS).
   - `BOOT_MODE` : `UEFI` ou `BIOS`.
   - `NUM_PARTITIONS` : Nombre de partitions à créer.

3. **Partitions :**
   - `PART1_TYPE`, `PART2_TYPE`, `PART3_TYPE`, `PART4_TYPE` : Types de partitions (ex. : `EFI`, `swap`, `home`, `root`).
   - `PART1_SIZE`, `PART2_SIZE`, `PART3_SIZE`, `PART4_SIZE` : Tailles des partitions (ex. : `10G`, `512M` , `100%`).
   - `PART1_FS` , `PART2_FS` , `PART3_FS` , `PART4_FS` : Système de fichiers (ex. : `fat32` , `swap` , `ext4`)
   - Assurez-vous que les partitions sont créées dans le bon ordre et que la partition `root` utilise tout l'espace restant.

4. **Système :**
   - `HOSTNAME` : Nom d'hôte pour votre système.
   - `LOCALE` : Locale du système (ex. : `fr_FR.UTF-8`).
   - `TIMEZONE` : Fuseau horaire (ex. : `Europe/Paris`).
   - `KEYMAP` : Mappage du clavier (ex. : `fr` pour azerty).

## Installation
1. Démarrez depuis le support live d'Arch Linux.
2. Montez le disque de votre choix et lancez le script d'installation :
   - `chmod +x install_arch.sh`
   - `./install_arch.sh`
3. Suivez les instructions affichées à l'écran. 
4. À la fin du processus, redémarrez votre système.

## Remarques
1. Assurez-vous d'avoir sauvegardé toutes les données importantes sur le disque cible, car ce script effacera toutes les partitions existantes.
2. Si vous rencontrez des problèmes, vérifiez le fichier de log pour les erreurs.
3. Pour des installations personnalisées, n'hésitez pas à modifier le script selon vos besoins.

## Auteurs
[KHOULKHALI Montasir]
[15/10/2024]

Merci d'avoir choisi cette méthode d'installation d'Arch Linux. Bonne chance !
