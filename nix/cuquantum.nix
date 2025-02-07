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
    "3.11" = "sha256-g/KYASroZdKsSEkfblCJy7iBSvfuUbrDeSQ1vUEhElk=";
    "3.12" = "sha256-xdjBundvspsiyKpaG9ishSiGuJg1Rg6F2v/CQx//mX4=";
  };
in
buildPythonPackage rec {
  pname = "cuquantum-python";
  version = "24.11.0";
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
    addAutoPatchelfSearchPath "${cudensitymat}/lib/${python.libPrefix}/site-packages/cuquantum/lib"
    addAutoPatchelfSearchPath "${custatevec}/lib/${python.libPrefix}/site-packages/cuquantum/lib"
    addAutoPatchelfSearchPath "${cutensornet}/lib/${python.libPrefix}/site-packages/cuquantum/lib"
    find $out -name "*cudensitymat*.so*" -exec patchelf --add-needed libcudensitymat.so.0 '{}' \;
    find $out -name "*custatevec*.so*" -exec patchelf --add-needed libcustatevec.so.1 '{}' \;
    find $out -name "*cutensornet*.so*" -exec patchelf --add-needed libcutensornet.so.2 '{}' \;
  '';
}
