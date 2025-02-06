{ lib
, buildPythonPackage
, fetchPypi
, cudaPackages
, autoPatchelfHook
, autoAddDriverRunpath
}:

buildPythonPackage (finalAttrs: {
  pname = "cutensornet";
  version = "2.6.0";
  format = "wheel";
  src = fetchPypi {
    inherit (finalAttrs) version format;
    pname = "${finalAttrs.pname}_cu${cudaPackages.cudaMajorVersion}";
    dist = "py3";
    python = "py3";
    platform = "manylinux2014_x86_64";
    hash = "sha256-ZLWCZ5xOFvrs2RQxAycjduhH5Lf/Asl83nLznqYkP14=";
  };
  buildInputs = [ cudaPackages.libcublas cudaPackages.libcusolver cudaPackages.cutensor ];
  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
})
