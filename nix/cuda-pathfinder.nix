{ buildPythonPackage
, fetchPypi
, lib
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
}
