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
    };
}
