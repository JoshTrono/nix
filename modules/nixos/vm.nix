# /.dotfiles/modules/vm.nix
# Virtual machines: libvirt + virt-manager, and VM Curator (drives QEMU
# directly, no libvirt), with UEFI firmware where VM Curator can find it and
# optional single-GPU passthrough (custom.vm.gpuPassthrough, off by default).
{
  flake.modules.nixos.vm =
    {
      config,
      lib,
      pkgs,
      vars,
      ...
    }:
    {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      virtualisation.libvirtd.qemu.swtpm.enable = true;

      users.users."${vars.username}".extraGroups = [ "libvirtd" ];
      environment.systemPackages = with pkgs; [
        dnsmasq
      ];
      networking.firewall.trustedInterfaces = [ "virbr0" ];
      # home.pointerCursor = {
      #   gtk.enable = true;
      #   package = pkgs.vanilla-dmz;
      #   name = "Vanilla-DMZ";
      # };

      virtualisation.docker = {
        enable = true;
        # Customize Docker daemon settings using the daemon.settings option
        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          log-driver = "journald";
          registry-mirrors = [ "https://mirror.gcr.io" ];
          storage-driver = "overlay2";
        };
        # Use the rootless mode - run Docker daemon as non-root user
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
}
