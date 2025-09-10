{
  description = "Nix derivations for quantum many-body physics and quantum computing";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        hphi = final.callPackage ./nix/hphi.nix { };
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            # NOTE: put your Python package overrides here
            autoray = python-final.callPackage ./nix/autoray.nix { };
            # cupy = python-final.callPackage ./nix/cupy.nix { };
            cuda-core = python-final.callPackage ./nix/cuda-core.nix { };
            cuda-bindings = python-final.callPackage ./nix/cuda-bindings.nix { };
            cuquantum = python-final.callPackage ./nix/cuquantum.nix { };
            custatevec = python-final.callPackage ./nix/custatevec.nix { };
            cutensornet = python-final.callPackage ./nix/cutensornet.nix { };
            cudensitymat = python-final.callPackage ./nix/cudensitymat.nix { };
            qsimcirq = python-final.callPackage ./nix/qsimcirq.nix { };
            parallel-sparse-tools = python-final.callPackage ./nix/parallel-sparse-tools.nix { };
            pyclibrary = python-final.callPackage ./nix/pyclibrary.nix { };
            quspin-extensions = python-final.callPackage ./nix/quspin-extensions.nix { };
            quspin = python-final.callPackage ./nix/quspin.nix { };
            # Disable failing joblib tests on Darwin
            joblib = python-prev.joblib.overridePythonAttrs (attrs:
              lib.optionalAttrs (final.stdenv.isDarwin && python-prev.python.pythonOlder "3.12") {
                disabledTests = (attrs.disabledTests or [ ]) ++ [ "test_parallel_with_interactively_defined_functions" ];
              });
            uniplot = python-final.callPackage ./nix/uniplot.nix { };
          })
        ];
      };

      import-nixpkgs-for = drv: cudaSupport: system: import drv {
        inherit system;
        config = { allowUnfree = true; } // lib.optionalAttrs cudaSupport {
          cudaSupport = true;
          cudaCapabilities = [ "7.0" ];
          cudaForwardCompat = true;
        };
        overlays = [ overlay ];
      };
      pkgs-for-cpu = import-nixpkgs-for inputs.nixpkgs false;
      pkgs-for-cuda = import-nixpkgs-for inputs.nixpkgs true;
    in
    {
      packages = forEachSystem (system: _: {
        cpu = { inherit (pkgs-for-cpu system) hphi python3Packages python311Packages python312Packages; };
        cuda = { inherit (pkgs-for-cuda system) cudaPackages python3Packages python311Packages python312Packages; };
      });
      overlays.default = overlay;
      devShells = forEachSystem (system: _: {
          default = let pkgs = pkgs-for-cpu system; in pkgs.mkShell { nativeBuildInputs = with pkgs; [ cachix ]; };
          # test = let pkgs = pkgs-for-cuda system; in pkgs.mkShell { nativeBuildInputs = with pkgs; [
          #   (python3.withPackages (ps: with ps; [ cuda-core cuda-bindings jax jaxlib jax-cuda12-plugin numpy ]))
          # ]; };
        });
      formatter = forEachSystem (system: pkgs: pkgs.nixpkgs-fmt);
    };
}
