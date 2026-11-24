# SSH server. Authorized keys come from `vars.sshKeys` (variables.nix).
# Password logins are only allowed while that list is empty, so a fresh install
# can never lock you out, and adding a key turns them off automatically.
{
  flake.modules.nixos.ssh =
    {
      config,
      lib,
      vars,
      ...
    }:
    let
      hasKeys = vars.sshKeys != [ ];
    in
    {
      users.users.${vars.username}.openssh.authorizedKeys.keys = vars.sshKeys;

      services.openssh = {
        # Hosts that don't need SSH can override this (Zeus does until it has a key).
        enable = lib.mkDefault true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = !hasKeys;
          KbdInteractiveAuthentication = !hasKeys;
        };
      };

      warnings = lib.optional (config.services.openssh.enable && !hasKeys) ''
        SSH password logins are still enabled because vars.sshKeys is empty.
        Add your public key to variables.nix to turn them off.
      '';
    };
}
