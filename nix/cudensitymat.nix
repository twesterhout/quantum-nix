{ lib
, buildPythonPackage
, fetchPypi
, cudaPackages
, autoPatchelfHook
, autoAddDriverRunpath
}:

buildPythonPackage rec {
  pname = "cudensitymat";
  version = "0.0.5";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "${pname}_cu${cudaPackages.cudaMajorVersion}";
    dist = "py3";
    python = "py3";
    platform = "manylinux2014_x86_64";
    hash = "sha256-651ggQ5wljbNQNe3Jo/djpYDCXErUULDq+kqnTyOBUg=";
  };
  buildInputs = [ cudaPackages.cuda_cudart cudaPackages.libcublas cudaPackages.cutensor ];
  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
}
