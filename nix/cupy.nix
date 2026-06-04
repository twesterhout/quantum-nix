{ autoAddDriverRunpath
, autoPatchelfHook
, buildPythonPackage
, config
, cudaPackages
, cuda-pathfinder
, fetchPypi
, lib
, numpy
, python
}:

let
  py = ''cp${lib.replaceStrings ["."] [""] python.pythonVersion}'';
in
buildPythonPackage rec {
  pname = "cupy";
  version = "14.1.1";
  format = "wheel";
  src = fetchPypi ({ inherit version format; dist = py; abi = py; python = py; platform = "manylinux2014_x86_64"; } // {
    "12" = { pname = "cupy_cuda12x"; hash = { "3.13" = "sha256-duo1Rp4qoKgzK4j3JQXqL3hxoLyPmwyHGE9X5Hyao78"; }."${python.pythonVersion}"; };
    "13" = { pname = "cupy_cuda13x"; hash = { "3.13" = "sha256-/0UmclwTmOoZ1XgERzeqJIWbCOH0aaugykXf1vmqUF0"; }."${python.pythonVersion}"; };
  }."${cudaPackages.cudaMajorVersion}");
  dependencies = [ numpy cuda-pathfinder ];
  buildInputs = with cudaPackages; [ nccl (lib.getLib libcusolver) (lib.getLib libcusparse) (lib.getLib libcufft)
    (lib.getLib libcublas) (lib.getLib libcurand) (lib.getLib cuda_cudart) (lib.getLib cuda_nvrtc) (lib.getLib libnvjitlink) ];
  nativeBuildInputs = [ autoPatchelfHook ];
  autoPatchelfIgnoreMissingDeps = [ "libcutensor.so.2" "libcutensorMg.so.2" ];
  meta = {
    description = "NumPy-compatible matrix library accelerated by CUDA";
    homepage = "https://cupy.chainer.org/";
    changelog = "https://github.com/cupy/cupy/releases/tag/${version}";
    license = lib.licenses.mit;
    platforms = [ "aarch64-linux" "x86_64-linux" ];
    maintainers = with lib.maintainers; [ twesterhout ];
  };
}
