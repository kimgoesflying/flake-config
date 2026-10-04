{
  description = "NixOS Configuration for ThinkPad T460s";

  inputs = {
    # Pinning your system to the stable NixOS 26.05 release branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = inputs: {
    nixosConfigurations = {
      # The name 't460s' is the target hostname you pass to nixos-rebuild
      t460s = inputs.nixpkgs.lib.nixosSystem {

        # Passes the 'inputs' variable down so downstream files can use external flakes
        specialArgs = { inherit inputs; };

        modules = [
          # 1. Locks the CPU target architecture for your ThinkPad
          { nixpkgs.hostPlatform = "x86_64-linux"; }

          # 2. Imports the global settings shared among all your machines
          ./common/global.nix

          # 3. Imports the configurations unique to this individual laptop
          ./hosts/t460s/configuration.nix
          ./hosts/t460s/hardware.nix
        ];
      };
    };
  };
}
