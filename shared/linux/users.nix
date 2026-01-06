{ config, pkgs, user, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${user} account";
    extraGroups = [ "networkmanager" "wheel" "docker" "fuse"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCerVUafXpWO0eupbHa/KMpvPlOT1ffnxf8JLnQr0pe7dTpvQSN153a5rAOQ/4+C1rh971Yew9aFntEyc34P3oJ21CoGNrYst7V9Dvym2A7C2fJy2VxwFfy1+Aq+hf55KRYYkTqJYFCarwd6oMekq11K8TGjZoWlg5fy/tigobtJGVwmwBYybkCWSaMI53MVYyerw2MYSWsrKUkdJ9YvgAjJkrnnu0WRq2i34+gb7/ohB/2iCIQ0WGRqJ1YeQQn//5/tQdigs1LwNVZIh/MCDuiX/PxgpgKBAhP9WBb0GgbXypd+bvA+xY9KazSABTaT+uKxZSIN46Uekz/PScsXz+DRu7OekKT22Z2yMjEX9Be/QtuW/0dLUav1TnIRKtR1C7X9Y2Hr6ULuFBEMF/igvq8w9DI4wlrLqwYb/4kXRMRAUbnxls7JQ2wGSGNhtA5mcTa/cVK7XtPJRxQzV2Ez/WjaLL9yVUt4uK8s+KypLczsSJ7ZnLkwm53xI+T3c4jakjVCHBZRiEct5R8wFlAL03MGMwg8fMozeiY4/Bc5ARngg5xGz0qdBhWQ2XTxZxL+6oERx7rdFBBwbDSprIEykDLDK4TtUKu3iNLk7AsSbbm6biile7F378wnBXMC7H1nNZiVK6sU/1+0u9ENv4kmvCo0iMjD1pcbKOZlRARvyDlHw== robert@Roberts-MBP.fritz.box"
    ];
  };
  # password-less sudo
  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "${user}";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
