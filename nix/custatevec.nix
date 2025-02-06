{ lib
, buildPythonPackage
, fetchPypi
, python
, cudaPackages
, autoPatchelfHook
, autoAddDriverRunpath
}:

buildPythonPackage rec {
  pname = "custatevec";
  version = "1.7.0";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "${pname}_cu${cudaPackages.cudaMajorVersion}";
    dist = "py3";
    python = "py3";
    platform = "manylinux2014_x86_64";
    hash = "sha256-34G07urchBtMOsSBbmuePd5rKI8TosAAX+y9BQH56m0=";
  };
  # The following is needed for CMake to be able to detect custatevec in find_library calls
  postFixup = ''
    pushd "$out/lib/${python.libPrefix}/site-packages/cuquantum/lib"
    ln --symbolic libcustatevec.so.1 libcustatevec.so
    popd
  '';
  buildInputs = [ cudaPackages.libcublas ];
  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];
}
