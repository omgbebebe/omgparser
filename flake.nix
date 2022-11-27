{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];
      perSystem = { self', pkgs, ... }: {
        haskellProjects.default = {
          packages = { 
            # You can add more than one local package here.
            omg.root = ./.;  # Assumes ./my-package.cabal
          };
          # buildTools = hp: { fourmolu = hp.fourmolu; ghcid = null; };
          # overrides = self: super: { };
          # hlintCheck.enable = true;
          # hlsCheck.enable = true;
          haskellPackages = pkgs.haskell.packages.ghc943.override {
            overrides = hsPkgs-old: hsPkgs-new: {
              monomer = hsPkgs-new.callHackageDirect {
                pkg = "monomer";
                ver = "1.5.0.0";
                sha256 = "87by+Safw9NvkRk2RqLr76a7jmVsTg+I2njExV0g7ck=";
              } {};
              sdl2 = pkgs.haskell.lib.dontCheck (hsPkgs-new.callHackageDirect {
                pkg = "sdl2";
                ver = "2.5.4.0";
                sha256 = "tG1mgGqyn3heGk5jt6V3jXrxvXtXaZh4nKLwlyZwnCQ=";
              } {});
              double-conversion = pkgs.haskell.lib.markUnbroken (pkgs.haskell.lib.overrideSrc hsPkgs-new.double-conversion {
                src = pkgs.fetchFromGitHub {
                  owner = "haskell";
                  repo = "double-conversion";
                  rev = "5d092e0664442eaac8ae1d101dba57ce9b1c9b03";
                  sha256 = "K+UJK5ek5ufplqY7to9lfVnSKoa+rZUjNL95b0P7R3w=";
                };
              });
              OpenGLRaw = pkgs.haskell.lib.doJailbreak hsPkgs-new.OpenGLRaw;
              nanovg = pkgs.haskell.lib.doJailbreak hsPkgs-new.nanovg;
              ListLike = pkgs.haskell.lib.dontCheck hsPkgs-new.ListLike;
              hspec-contrib = hsPkgs-new.callHackageDirect {
                pkg = "hspec-contrib";
                ver = "0.5.1.1";
                sha256 = "5Re0AUYWQXv/05B1rB4uXMdlCwf1/h0U4YOqlimUKW8=";
              } {};
              hlint = hsPkgs-new.callHackageDirect {
                pkg = "hlint";
                ver = "3.5";
                sha256 = "qQNUlQQnahUGEO92Lm0RwjTGBGr2Yaw0KRuFRMoc5No=";
              } {};
            };
          };
        };
        # haskell-flake doesn't set the default package, but you can do it here.
        packages.default = self'.packages.omg;
      };
    };
}
