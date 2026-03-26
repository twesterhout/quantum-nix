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
, cuda-core
, cuda-bindings

, tree
}:

let
  py = ''cp${lib.replaceStrings ["."] [""] python.pythonVersion}'';
  binary = buildPythonPackage rec {
    pname = "nvmath-python";
    version = "0.8.0";
    format = "wheel";
    src = fetchPypi {
      inherit version format;
      pname = "nvmath_python";
      dist = py;
      abi = py;
      python = py;
      platform = "manylinux_2_28_x86_64";
      hash = {
        "3.13" = "sha256-z5jsnL5Lk6MWRVaThhz88MrKMGSz+TzMyT67cE2CUH4";
      }."${python.pythonVersion}";
    };
    # preFixup = ''
    #   find $out -name "*cynvrtc*.so*" -exec patchelf --add-needed libnvrtc.so '{}' \;
    #   find $out -name "*cynvjitlink*.so*" -exec patchelf --add-needed libnvJitLink.so '{}' \;
    #   find $out -name "*cyruntime*.so*" -exec patchelf --add-needed libcudart.so '{}' \;

    #   pushd "$out/${python.sitePackages}/cuda"
    #   find . -type f -name '*.h' -exec rm -v '{}' \;
    #   find . -type f -name '*.cpp' -exec rm -v '{}' \;
    #   find . -type f -name '*.pyx' -exec rm -v '{}' \;
    #   find . -type f -name '*.pxd' -exec rm -v '{}' \;
    #   popd
    # '';
    dependencies = [ numpy cuda-bindings cuda-core ];
    # buildInputs = with cudaPackages; [ cuda_cudart.lib cuda_nvrtc.lib libnvjitlink.lib ];
    nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
  };
in
  binary
