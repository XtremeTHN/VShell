{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      astal,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      nativeBuildInputs = with pkgs; [
        meson
        ninja
        vala
        pkg-config
        wrapGAppsHook4
        blueprint-compiler
      ];

      buildInputs = with astal.packages.${system}; [
        io
        astal4
        battery
        hyprland
        wireplumber
        mpris
        tray
        bluetooth
        apps
        notifd
        network
        cava
        powerprofiles

        pkgs.dart-sass
        pkgs.gobject-introspection
        pkgs.gtk4
        pkgs.gtk4-layer-shell
        pkgs.libadwaita
      ];

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit nativeBuildInputs buildInputs;

        packages = with pkgs; [
          gdb
          uncrustify
          vala-language-server
        ];
      };
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "vshell";
        version = "0.1.0";
        src = ./.;

        inherit nativeBuildInputs buildInputs;
      };
    };
}
