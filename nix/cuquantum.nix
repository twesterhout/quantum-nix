{ lib
, buildPythonPackage
, python
, fetchPypi
, autoPatchelfHook
, patchelf
, custatevec
, cudensitymat
, cutensornet
, cudaPackages
, autoAddDriverRunpath
}:

let
  py = ''cp${lib.replaceStrings ["."] [""] python.pythonVersion}'';
  hashes = {
    "3.13" = "sha256-Qv5LmK3amJOU14Omx3YuH8lcXGeny5BpcWvKFmhw90I";
  };
in
buildPythonPackage rec {
  pname = "cuquantum-python";
  version = "25.9.0";
  format = "wheel";
  src = fetchPypi {
    inherit version format;
    pname = "cuquantum_python_cu${cudaPackages.cudaMajorVersion}";
    dist = py;
    abi = py;
    python = py;
    platform = "manylinux2014_x86_64";
    hash = hashes."${python.pythonVersion}";
  };
  dependencies = [ custatevec cudensitymat cutensornet ];
  nativeBuildInputs = [ patchelf autoPatchelfHook autoAddDriverRunpath ];
  postInstall = ''
    addAutoPatchelfSearchPath "${cudensitymat}/${python.sitePackages}/cuquantum/lib"
    addAutoPatchelfSearchPath "${custatevec}/${python.sitePackages}/cuquantum/lib"
    addAutoPatchelfSearchPath "${cutensornet}/${python.sitePackages}/cuquantum/lib"
    find $out -name "*cudensitymat*.so*" -exec patchelf --add-needed libcudensitymat.so.0 '{}' \;
    find $out -name "*custatevec*.so*" -exec patchelf --add-needed libcustatevec.so.1 '{}' \;
    find $out -name "*cutensornet*.so*" -exec patchelf --add-needed libcutensornet.so.2 '{}' \;
  '';
}
