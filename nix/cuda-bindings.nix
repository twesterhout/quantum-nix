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
  pname = "cuda-bindings";
  version = {
    "12" = "12.9.7";
  }."${cudaPackages.cudaMajorVersion}";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "cuda_bindings";
    dist = py;
    abi = py;
    python = py;
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = {
      "12" = { "3.13" = "sha256-Wc9KN7DWYroVA3yc7r4aMG6/LAGoI1oJvhPNBwlP23Q"; }."${python.pythonVersion}";
    }."${cudaPackages.cudaMajorVersion}";
  };
  preFixup = ''
    find $out -name "*cudart*.so*" -exec patchelf --add-needed libcudart.so '{}' \;
    find $out -name "*nvrtc*.so*" -exec patchelf --add-needed libnvrtc.so '{}' \;
    find $out -name "*nvjitlink*.so*" -exec patchelf --add-needed libnvJitLink.so '{}' \;
    find $out -name "*runtime*.so*" -exec patchelf --add-needed libcudart.so '{}' \;
  '';
  dependencies = [ numpy cuda-pathfinder ];
  buildInputs = with cudaPackages; [ (lib.getLib cuda_cudart) (lib.getLib cuda_nvrtc) (lib.getLib libnvjitlink) ];
  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
}
