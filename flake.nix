{
  description = "Nix derivations for quantum many-body physics";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-gl-host.url = "github:numtide/nix-gl-host";
    nix-gl-host.inputs.nixpkgs.follows = "nixpkgs";
  };
  nixConfig = {
    extra-substituters = [
      "https://twesterhout.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "twesterhout.cachix.org-1:AtBrVtHiRtg7piQOwT9IWx3N/+q+lM6RrpxzpeT3zAE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = inputs:
    let
      lib = inputs.nixpkgs.lib;
      forEachSystem = f: lib.mapAttrs f inputs.nixpkgs.legacyPackages;

      overlay = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            # NOTE: put your Python package overrides here
            cupy = python-final.callPackage ./nix/cupy.nix { };
            cuquantum = python-final.callPackage ./nix/cuquantum.nix { };
            custatevec = python-final.callPackage ./nix/custatevec.nix { };
            cutensornet = python-final.callPackage ./nix/cutensornet.nix { };
            cudensitymat = python-final.callPackage ./nix/cudensitymat.nix { };
            qsimcirq = python-final.callPackage ./nix/qsimcirq.nix { };
          })
        ];
      };

      import-nixpkgs-for = drv: system: import drv {
        inherit system;
        config = { allowUnfree = true; } // lib.optionalAttrs (system == "x86_64-linux") {
          cudaSupport = true; cudaCapabilities = [ "7.0" ]; cudaForwardCompat = true; };
        overlays = [ overlay ] ++ lib.optionals (system == "x86_64-linux") [ inputs.nix-gl-host.overlays.default ];
      };
      pkgs-for = import-nixpkgs-for inputs.nixpkgs;

      pythonEnv = pkgs: pkgs.python3.withPackages (ps: with ps; [
        jaxlib
        jax
        cuquantum
        qsimcirq
        cupy
      ]);
    in
    {
      packages = forEachSystem (system: _:
        let pkgs = pkgs-for system; in {
          inherit (pkgs) python3Packages;
        });
      overlays.default = overlay;
      devShells = forEachSystem (system: _:
        let pkgs = pkgs-for system; in {
          default = pkgs.mkShell { nativeBuildInputs = with pkgs; [ cachix ]; };
        });
      formatter = forEachSystem (system: pkgs: pkgs.nixpkgs-fmt);
    };
}
