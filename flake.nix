{
  description = "A Python project template with CUDA GPU support";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-gl-host.url = "github:numtide/nix-gl-host";
    nix-gl-host.inputs.nixpkgs.follows = "nixpkgs";
  };
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" "https://cuda-maintainers.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = inputs:
    let
      lib = inputs.nixpkgs.lib;
      forEachSystem = f: lib.mapAttrs f inputs.nixpkgs.legacyPackages;

      overlay = final: prev: {
        # cuquantum = final.stdenv.mkDerivation (finalAttrs: {
        #   pname = "cuquantum";
        #   version = "24.11.0.21";
        #   src = final.fetchzip {
        #     url = "https://developer.download.nvidia.com/compute/cuquantum/redist/cuquantum/linux-x86_64/cuquantum-linux-x86_64-${finalAttrs.version}_cuda${final.cudaPackages.cudaMajorVersion}-archive.tar.xz";
        #     hash = "sha256-uRebtd5G7AAJj1zdHKB+F/wyHr/2lR6CcTWLAslTJq8=";
        #   };
        #   dontConfigure = true;
        #   dontBuild = true;
        #   installPhase = ''
        #     runHook preInstall
        #     mkdir -p $out
        #     cp -r include lib $out/
        #     tree $out
        #     runHook postInstall
        #   '';
        #   buildInputs = with final; [ cudaPackages.cuda_cudart cudaPackages.libcublas cudaPackages.libcusolver cudaPackages.cutensor ];
        #   nativeBuildInputs = [ final.tree final.autoPatchelfHook final.autoAddDriverRunpath ];
        # });
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            # NOTE: put your Python package overrides here
            cupy = python-final.callPackage ./cupy.nix { };
            # cuquantum = python-final.buildPythonPackage rec {
            #   pname = "cuquantum";
            #   version = "24.11.0";
            #   format = "wheel";
            #   src = python-final.fetchPypi {
            #     inherit pname version format;
            #     pname = "${pname}_cu${final.cudaPackages.cudaMajorVersion}";
            #     dist = "py3";
            #     python = "py3";
            #     platform = "manylinux2014_x86_64";
            #     hash = "";
            #   };
            #   dependencies = with python-final; [ numpy cupy custatevec cutensornet cudensitymat ];
            #   nativeBuildInputs = [ final.autoPatchelfHook final.autoAddDriverRunpath ];
            # };
            cuquantum = python-final.buildPythonPackage rec {
              pname = "cuquantum-python";
              version = "24.11.0";
              format = "wheel";
              src = let pythonVersion = lib.replaceStrings ["."] [""] python-final.python.pythonVersion; in python-final.fetchPypi {
                inherit version format;
                pname = "cuquantum_python_cu${final.cudaPackages.cudaMajorVersion}";
                dist = "cp${pythonVersion}";
                abi = "cp${pythonVersion}";
                python = "cp${pythonVersion}";
                platform = "manylinux2014_x86_64";
                hash = "sha256-xdjBundvspsiyKpaG9ishSiGuJg1Rg6F2v/CQx//mX4=";
              };
              dependencies = with python-final; [ custatevec cudensitymat cutensornet ];
              nativeBuildInputs = [ final.tree final.patchelf final.autoPatchelfHook final.autoAddDriverRunpath ];
              postInstall = with python-final; ''
                addAutoPatchelfSearchPath "${cudensitymat}/lib/${python.libPrefix}/site-packages/cuquantum/lib"
                addAutoPatchelfSearchPath "${custatevec}/lib/${python.libPrefix}/site-packages/cuquantum/lib"
                addAutoPatchelfSearchPath "${cutensornet}/lib/${python.libPrefix}/site-packages/cuquantum/lib"
                find $out -name "*cudensitymat*.so*" -exec patchelf --add-needed libcudensitymat.so.0 '{}' \;
                find $out -name "*custatevec*.so*" -exec patchelf --add-needed libcustatevec.so.1 '{}' \;
                find $out -name "*cutensornet*.so*" -exec patchelf --add-needed libcutensornet.so.2 '{}' \;
              '';
            };
            custatevec = python-final.buildPythonPackage rec {
              pname = "custatevec";
              version = "1.7.0";
              format = "wheel";
              src = python-final.fetchPypi {
                inherit version format;
                pname = "${pname}_cu${final.cudaPackages.cudaMajorVersion}";
                dist = "py3";
                python = "py3";
                platform = "manylinux2014_x86_64";
                hash = "sha256-34G07urchBtMOsSBbmuePd5rKI8TosAAX+y9BQH56m0=";
              };
              # The following is needed for CMake to be able to detect custatevec in find_library calls
              postFixup = ''
                pushd "$out/lib/${python-final.python.libPrefix}/site-packages/cuquantum/lib"
                ln --symbolic libcustatevec.so.1 libcustatevec.so
                popd
              '';
              buildInputs = with final; [ cudaPackages.libcublas ];
              nativeBuildInputs = [ final.autoPatchelfHook final.autoAddDriverRunpath ];
            };
            cutensornet = python-final.buildPythonPackage rec {
              pname = "cutensornet";
              version = "2.6.0";
              format = "wheel";
              src = python-final.fetchPypi {
                inherit version format;
                pname = "${pname}_cu${final.cudaPackages.cudaMajorVersion}";
                dist = "py3";
                python = "py3";
                platform = "manylinux2014_x86_64";
                hash = "sha256-ZLWCZ5xOFvrs2RQxAycjduhH5Lf/Asl83nLznqYkP14=";
              };
              buildInputs = with final; [ cudaPackages.libcublas cudaPackages.libcusolver cudaPackages.cutensor ];
              nativeBuildInputs = [ final.autoPatchelfHook final.autoAddDriverRunpath ];
            };
            cudensitymat = python-final.buildPythonPackage rec {
              pname = "cudensitymat";
              version = "0.0.5";
              format = "wheel";
              src = python-final.fetchPypi {
                inherit version format;
                pname = "${pname}_cu${final.cudaPackages.cudaMajorVersion}";
                dist = "py3";
                python = "py3";
                platform = "manylinux2014_x86_64";
                hash = "sha256-651ggQ5wljbNQNe3Jo/djpYDCXErUULDq+kqnTyOBUg=";
              };
              buildInputs = with final; [ cudaPackages.cuda_cudart cudaPackages.libcublas cudaPackages.cutensor ];
              nativeBuildInputs = [ final.autoPatchelfHook final.autoAddDriverRunpath ];
            };
            qsimcirq = python-final.buildPythonPackage rec {
              pname = "qsimcirq";
              version = "0.21.0";
              format = "setuptools";
              stdenv = final.cudaPackages.backendStdenv;
              src = final.fetchFromGitHub {
                owner = "quantumlib";
                repo = "qsim";
                tag = "v0.21.0";
                hash = "sha256-GqUUA3In/euG9KVBKVvapblSlYB6GBYJX8O80cu7vm4=";
              };
              dontUseCmakeConfigure = true;
              CUDAARCHS = final.cudaPackages.flags.cmakeCudaArchitecturesString;
              CUQUANTUM_ROOT = "${python-final.custatevec}/lib/${python-final.python.libPrefix}/site-packages/cuquantum";
              dependencies = with python-final; [ absl-py cirq-core numpy typing-extensions ];
              buildInputs = with final; [ python-final.pybind11 cudaPackages.cuda_cudart cudaPackages.cuda_cccl cudaPackages.libcublas ];
              nativeBuildInputs = with python-final; [ final.tree final.which final.cudaPackages.cuda_nvcc setuptools final.cmake ];
            };
          })
        ];
      };

      import-nixpkgs-for = drv: system: import drv {
        inherit system;
        config = { cudaSupport = true; allowUnfree = true; cudaCapabilities = [ "7.0" ]; cudaForwardCompat = true; };
        overlays = [ inputs.nix-gl-host.overlays.default overlay ];
      };
      pkgs-for = import-nixpkgs-for inputs.nixpkgs;
      patched-nixpkgs-for = pkgs-for;
      # patched-nixpkgs-for = system:
      #   let
      #     pkgs' = inputs.nixpkgs.legacyPackages."${system}".applyPatches {
      #       name = "nixpkgs-patched";
      #       src = inputs.nixpkgs;
      #       patches = [
      #         # https://github.com/NixOS/nixpkgs/pull/359647 fixes cupy builds
      #         (builtins.fetchurl {
      #           url = "https://github.com/NixOS/nixpkgs/pull/359647/commits/bcbc451147e07e51bf3ca5fee630d65ac2a99600.diff";
      #           sha256 = "sha256:1cp1qzpzzl4wqgmnz6chlzxy50lldsp8cqzwzrgic0xwvhskmc1p";
      #         })
      #         (builtins.fetchurl {
      #           url = "https://github.com/NixOS/nixpkgs/pull/359647/commits/011e53fa62ac7c9ee8042f9a14f5050d541fe10e.diff";
      #           sha256 = "sha256:1w2ylza7mw1q5lg5a3a0rv88mdqcir8zmwymdddd11rnxkzy3mxn";
      #         })
      #       ];
      #     };
      #   in
      #   import-nixpkgs-for pkgs' system;

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
        let pkgs = patched-nixpkgs-for system; in {
          inherit (pkgs) python3Packages;
        });
      devShells = forEachSystem (system: _:
        let pkgs = patched-nixpkgs-for system; in {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ nix-gl-host nix-tree patchelf (pythonEnv pkgs) ];
            # shellHook = ''
            #   export CUQUANTUM=${pkgs.cuquantum}
            # '';
            shellHook = ''
              # CuPy can't find libnvrtc
              export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH
              # export LD_LIBRARY_PATH=${pkgs.cudaPackages.cuda_nvrtc.lib}/lib:$LD_LIBRARY_PATH
            '';
          };
        });
      overlays.default = overlay;
      formatter = forEachSystem (system: pkgs: pkgs.nixpkgs-fmt);
    };
}
