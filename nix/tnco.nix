{ buildPythonPackage
, fetchFromGitHub
, autoray
, more-itertools
, boost
, ninja
, pybind11
, cmake
, setuptools
, scikit-build-core
}:

buildPythonPackage {
  pname = "tnco";
  version = "0.1";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "google-research";
    repo = "tnco";
    rev = "70f9bc27af3d15429207a5d075e97a55f656b06e";
    hash = "sha256-hxF0ziTkgd8MSfg1oj0FUi6OvYzvU9hJq79ShULUIGA";
  };
  patches = [ ./0001-HACK-Reduce-dependency-footprint.patch ];
  dontUseCmakeConfigure = true;
  dependencies = [ autoray more-itertools ];
  buildInputs = [ boost ninja pybind11 ];
  nativeBuildInputs = [ cmake setuptools scikit-build-core ];
  doCheck = false;
}
