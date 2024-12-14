# Installation Automatisée d'Arch Linux

Ce script permet d'installer et de configurer automatiquement Arch Linux avec des options personnalisables.

## Prérequis
- Un environnement live d'Arch Linux (ex. : USB bootable).
- Connexion Internet.
- Disque dur ou SSD pour l'installation.
- Un accès à la ligne de commande.

## Configuration
Avant d'exécuter le script, vous devez modifier le fichier de configuration `config.cfg` selon vos besoins. Voici les options disponibles :

### 1. **Réseau :**
   - `USE_DHCP` : `true` pour utiliser DHCP, `false` pour une configuration manuelle.
   - `IP_ADDRESS`, `CIDR`, `GATEWAY`, `DNS` : Utilisez ces variables si `USE_DHCP` est `false`.

### 2. **Disques :**
   - `DISK` : Chemin du disque principal (ex. : `/dev/sda`).
   - `PARTITION_TABLE_TYPE` : Type de table de partition (`gpt` ou `msdos` pour BIOS).
   - `BOOT_MODE` : `UEFI` ou `BIOS`.
   - `NUM_PARTITIONS` : Nombre total de partitions.

### 3. **Partitions :**
   Au lieu de spécifier uniquement les tailles, les partitions utilisent désormais des valeurs explicites pour définir **le début et la fin**.

   | Partition | Type          | Début (`START`) | Fin (`END`)    | Système de Fichiers |
   |-----------|---------------|-----------------|---------------|---------------------|
   | PART1     | EFI/Boot      | `1MiB`          | `512MiB`      | `fat32`             |
   | PART2     | Swap          | `512MiB`        | `2.5GiB`      | `swap`              |
   | PART3     | Home          | `2.5GiB`        | `12.5GiB`     | `ext4`              |
   | PART4     | Root          | `12.5GiB`       | `100%`        | `ext4`              |

   Les variables correspondantes dans `config.cfg` sont :

   - `PART1_START` et `PART1_END`
   - `PART2_START` et `PART2_END`
   - `PART3_START` et `PART3_END`
   - `PART4_START` et `PART4_END`

   Exemple dans `config.cfg` :
   ```bash
   PART1_START=1MiB
   PART1_END=512MiB
   PART2_START=512MiB
   PART2_END=2.5GiB
   PART3_START=2.5GiB
   PART3_END=12.5GiB
   PART4_START=12.5GiB
   PART4_END=100%

## Auteurs
[KHOULKHALI Montasir]
[15/10/2024]

Merci d'avoir choisi cette méthode d'installation d'Arch Linux. Bonne chance !
