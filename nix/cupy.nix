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
  version = "14.0.1";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "cupy_cuda13x";
    dist = py;
    abi = py;
    python = py;
    platform = "manylinux2014_x86_64";
    hash = {
      "3.13" = "sha256-HCBkg6rqQM04v70aKfTfDBnVVdMG/+Q+8W852w5+en8"; # sha256-Ify06RfkMjftzF46GhJB4qKUa6nld842/VgL2YVvkeg";
    }."${python.pythonVersion}";
  };
  # preFixup = ''
  #   find $out -name "*cusolver*.so*" -exec patchelf --remove-needed libcusolver.so.11 '{}' \;
  #   find $out -name "*cutensor*.so*" -exec patchelf --remove-needed libcutensor.so.2 --remove-needed libcutensorMg.so.2 '{}' \;
  #   find $out -name "*cusparse*.so*" -exec patchelf --remove-needed libcusparse.so.12 '{}' \;
  #   find $out -name "*cufft*.so*" -exec patchelf --remove-needed libcufft.so.11 '{}' \;
  # '';
  dependencies = [ numpy cuda-pathfinder ];
  buildInputs = with cudaPackages; [ nccl (lib.getLib libcusolver) (lib.getLib libcusparse) (lib.getLib libcufft)
    (lib.getLib libcublas) (lib.getLib libcurand) (lib.getLib cuda_cudart) (lib.getLib cuda_nvrtc) (lib.getLib libnvjitlink) ];
  nativeBuildInputs = [ autoPatchelfHook ]; # autoAddDriverRunpath ];
  autoPatchelfIgnoreMissingDeps = [ "libcutensor.so.2" "libcutensorMg.so.2" ];
}
