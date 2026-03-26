{ buildPythonPackage
, fetchPypi
, lib
, cudaPackages
, python
}:

buildPythonPackage rec {
  pname = "cuda-pathfinder";
  version = "1.5.0";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "cuda_pathfinder";
    dist = "py3";
    abi = "none";
    python = "py3";
    hash = "sha256-SY+QqeneNgRKeSR0KuzOEcUMSfc18bxT4FqkbenqQRA";
  };
  preFixup = with cudaPackages; ''
    ls $out/${python.sitePackages}
    substituteInPlace $out/${python.sitePackages}/cuda/pathfinder/_dynamic_libs/descriptor_catalog.py \
      --replace-fail 'packaged_with="ctk"' 'packaged_with="driver"' \
      --replace-fail 'packaged_with="other"' 'packaged_with="driver"' \
      --replace-fail 'libcudart.so' '${lib.getLib cuda_cudart}/lib/libcudart.so' \
      --replace-fail 'libnvJitLink.so' '${lib.getLib libnvjitlink}/lib/libnvJitLink.so' \
      --replace-fail 'libnvrtc.so' '${lib.getLib cuda_nvrtc}/lib/libnvrtc.so' \
      --replace-fail 'libcublas.so' '${lib.getLib libcublas}/lib/libcublas.so' \
      --replace-fail 'libcublasLt.so' '${lib.getLib libcublas}/lib/libcublasLt.so' \
      --replace-fail 'libcufft.so' '${lib.getLib libcufft}/lib/libcufft.so' \
      --replace-fail 'libcufftw.so' '${lib.getLib libcufft}/lib/libcufftw.so' \
      --replace-fail 'libcurand.so' '${lib.getLib libcurand}/lib/libcurand.so' \
      --replace-fail 'libcusolver.so' '${lib.getLib libcusolver}/lib/libcusolver.so' \
      --replace-fail 'libcusparse.so' '${lib.getLib libcusparse}/lib/libcusparse.so' \
      --replace-fail 'libcupti.so' '${lib.getLib cuda_cupti}/lib/libcupti.so' \
      --replace-fail 'libnccl.so' '${lib.getLib nccl}/lib/libnccl.so'
  '';
}
