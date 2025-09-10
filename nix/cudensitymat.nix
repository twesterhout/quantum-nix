{ lib
, python
, buildPythonPackage
, fetchPypi
, cudaPackages
, cutensornet
, autoPatchelfHook
, autoAddDriverRunpath
}:

buildPythonPackage rec {
  pname = "cudensitymat";
  version = "0.3.0";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "${pname}_cu${cudaPackages.cudaMajorVersion}";
    dist = "py3";
    python = "py3";
    platform = "manylinux2014_x86_64";
    hash = "sha256-jXA/gkONvbSdn8cUhjCokCb3SY6xSEawLLTJElBlLbQ";
  };
  postPatch = ''
    addAutoPatchelfSearchPath ${cutensornet}/${python.sitePackages}/cuquantum/lib
  '';
  dependencies = [ cutensornet ];
  buildInputs = [ cudaPackages.cuda_cudart cudaPackages.libcublas cudaPackages.cutensor cudaPackages.libcurand cudaPackages.libcusolver ];
  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
}
