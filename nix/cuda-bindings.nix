{ autoAddDriverRunpath
, autoPatchelfHook
, buildPythonPackage
, config
, cudaPackages
, cython
, fetchFromGitHub
, fetchPypi
, lib
, numpy
, python
, pyclibrary
, pytestCheckHook
, pythonRelaxDepsHook
, setuptools
, symlinkJoin

, tree
}:

let
  outpaths = with cudaPackages; [
    cuda_cudart
    cuda_nvcc # <crt/host_defines.h>
    cuda_nvrtc
    cuda_profiler_api
    libnvjitlink
  ];
  cudatoolkit-joined = symlinkJoin {
    name = "cudatoolkit-joined-${cudaPackages.cudaVersion}";
    paths = outpaths ++ lib.concatMap (f: lib.map f outpaths) [ lib.getLib lib.getDev (lib.getOutput "static") (lib.getOutput "stubs") ];
  };

  source = buildPythonPackage rec {
    pname = "cuda-bindings";
    version = "12.8.0";
    format = "pyproject";
    src = fetchFromGitHub {
      owner = "NVIDIA";
      repo = "cuda-python";
      tag = "v${version}";
      hash = "sha256-7e9w70KkC6Pcvyu6Cwt5Asrc3W9TgsjiGvArRTer6Oc";
    };
    stdenv = cudaPackages.backendStdenv;
    postPatch = "cd cuda_bindings/";
    CUDA_PATH = "${cudatoolkit-joined}";
    enableParallelBuilding = true;
    buildInputs = with cudaPackages; [ cuda_cudart.lib cuda_nvrtc.lib libnvjitlink.lib ];
    preFixup = ''
      find $out -name "*cynvrtc*.so*" -exec patchelf --add-needed libnvrtc.so '{}' \;
      find $out -name "*cynvjitlink*.so*" -exec patchelf --add-needed libnvJitLink.so '{}' \;
      find $out -name "*cyruntime*.so*" -exec patchelf --add-needed libcudart.so '{}' \;

      pushd "$out/${python.sitePackages}/cuda"
      find . -type f -name '*.cpp' -exec rm -v '{}' \;
      find . -type f -name '*.pyx' -exec rm -v '{}' \;
      find . -type f -name '*.pxd' -exec rm -v '{}' \;
      popd
    '';
    nativeBuildInputs = [ cython pyclibrary setuptools pythonRelaxDepsHook autoAddDriverRunpath autoPatchelfHook tree ];
    doCheck = false; # Tests simply don't want to work...
    nativeCheckInputs = [ numpy pytestCheckHook ];
    enabledTestPaths = [ "tests/" ];
  };

  py = ''cp${lib.replaceStrings ["."] [""] python.pythonVersion}'';
  binary = buildPythonPackage rec {
    pname = "cuda-bindings";
    version = "12.8.0";
    format = "wheel";
    src = fetchPypi {
      inherit version format;
      pname = "cuda_bindings";
      dist = py;
      abi = py;
      python = py;
      platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
      hash = {
        "3.13" = "sha256-CZ8n5551Q0b6UVFxaHh82jlftDezH78gdxwALzCtwMk";
      }."${python.pythonVersion}";
    };
    preFixup = ''
      find $out -name "*cynvrtc*.so*" -exec patchelf --add-needed libnvrtc.so '{}' \;
      find $out -name "*cynvjitlink*.so*" -exec patchelf --add-needed libnvJitLink.so '{}' \;
      find $out -name "*cyruntime*.so*" -exec patchelf --add-needed libcudart.so '{}' \;

      pushd "$out/${python.sitePackages}/cuda"
      find . -type f -name '*.h' -exec rm -v '{}' \;
      find . -type f -name '*.cpp' -exec rm -v '{}' \;
      find . -type f -name '*.pyx' -exec rm -v '{}' \;
      find . -type f -name '*.pxd' -exec rm -v '{}' \;
      popd
    '';
    buildInputs = with cudaPackages; [ cuda_cudart.lib cuda_nvrtc.lib libnvjitlink.lib ];
    nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
  };
in
  binary
