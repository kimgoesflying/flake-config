{
  description = "NixOS Configuration for ThinkPad T460s";

  inputs = {
    # Pinning your system to the stable NixOS 26.05 release branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Add the latest Niri development flake
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    nixosConfigurations = {
      # The name 't460s' is the target hostname you pass to nixos-rebuild
      t460s = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          inputs.niri.nixosModules.niri
          ./common/global.nix
          ./hosts/t460s/configuration.nix
          ./hosts/t460s/hardware.nix
        ];
      };
    };
  };
}
