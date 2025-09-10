{ autoAddDriverRunpath
, buildPythonPackage
, config
, cudaPackages
, cython
, fetchFromGitHub
, lib
, numpy
, pyclibrary
, pytestCheckHook
, pythonRelaxDepsHook
, setuptools
, symlinkJoin
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
in
buildPythonPackage rec {
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
  doCheck = false; # Tests simply don't want to work...
  nativeBuildInputs = [ cython pyclibrary setuptools pythonRelaxDepsHook autoAddDriverRunpath ];
  pythonRelaxDeps = [ "cython" ];
  nativeCheckInputs = [ numpy pytestCheckHook ];
  enabledTestPaths = [ "tests/" ];
}
