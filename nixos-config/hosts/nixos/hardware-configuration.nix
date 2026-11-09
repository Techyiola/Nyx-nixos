# =============================================================================
#  REPLACE THIS FILE ON THE TARGET MACHINE
# =============================================================================
#
# This is a placeholder. It does NOT describe the real disks, swap, or kernel
# modules, so the system will not boot if you leave it as-is.
#
# On the NixOS installer, after mounting the target root:
#
#   sudo nixos-generate-config --root /mnt
#
# That writes:
#   /mnt/etc/nixos/hardware-configuration.nix
#
# Copy that file over this one, then rebuild:
#
#   sudo nixos-install --flake /mnt/home/techyiola/nixos-config#nixos
#
# The generated file will contain the btrfs subvolumes (@, @home, @var_log,
# ...), /boot vfat partition, zram/swap, and the amdgpu/nvidia kernel modules
# for this laptop.
# =============================================================================
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Intentionally empty: run `nixos-generate-config` on the target and paste
  # its output here. At minimum it must define:
  #
  #   fileSystems."/"
  #   fileSystems."/boot"
  #   fileSystems."/home"
  #   swapDevices
  #   boot.initrd.availableKernelModules
  #   boot.initrd.kernelModules
  #   boot.kernelModules
  #
  # Do not copy /etc/fstab from CachyOS: NixOS uses fileSystems.* instead.
}
