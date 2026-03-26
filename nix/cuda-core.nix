{ lib
, autoPatchelfHook
, autoAddDriverRunpath
, buildPythonPackage
, fetchPypi
, cudaPackages
, python
, cython
, numpy
, cuda-bindings
, setuptools
, pytestCheckHook
, pytest
}:

# buildPythonPackage rec {
#   pname = "cuda-core";
#   version = "0.3.3a0";
#   pyproject = true;
#   src = fetchFromGitHub {
#     owner = "NVIDIA";
#     repo = "cuda-python";
#     tag = "v12.8.0";
#     hash = "sha256-7e9w70KkC6Pcvyu6Cwt5Asrc3W9TgsjiGvArRTer6Oc";
#   };
#   postPatch = "cd cuda_core/";
#   dependencies = [ numpy cuda-bindings ];
#   build-system = [ cython setuptools pytest ];
#   nativeCheckInputs = [ pytestCheckHook ];
#   enabledTestPaths = [ "tests/" ];
#   # Can't run tests because Python gets confused about where to import which module from.
#   # cuda-bindings has the top-level cuda module, and for some reason Python
#   # tries to import cuda.core from cuda-bindings instead of from cuda-core.
#   # And this is not even related to https://github.com/NixOS/nixpkgs/issues/255262
#   doCheck = false;
# }
let
  py = ''cp${lib.replaceStrings ["."] [""] python.pythonVersion}'';
  binary = buildPythonPackage rec {
    pname = "cuda-core";
    version = "0.6.0";
    format = "wheel";
    src = fetchPypi {
      inherit version format;
      pname = "cuda_core";
      dist = py;
      abi = py;
      python = py;
      platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
      hash = {
        "3.13" = "sha256-oDDNgcvGJe10fQs2eNIVnmXnxxrRxiSA/wXgfl4F1as";
      }."${python.pythonVersion}";
    };
    buildInputs = with cudaPackages; [ numpy cuda-bindings ];
    nativeBuildInputs = [ autoPatchelfHook ];
  };
in
  binary
