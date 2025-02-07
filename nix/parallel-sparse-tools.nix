{ lib
, buildPythonPackage
, fetchFromGitHub
, python
, numpy
, scipy
, setuptools
, cython
, pytestCheckHook
}:

buildPythonPackage {
  pname = "parallel-sparse-tools";
  version = "0.2.3";
  src = fetchFromGitHub {
    owner = "QuSpin";
    repo = "parallel-sparse-tools";
    rev = "ef72b076a0f50bab56afdec709f284ed63aa4dbf";
    hash = "sha256-/Lf6vVrXB80tLOKFdMxGMdsNj3w3HScW4tmgGLIBoQk=";
  };
  pyproject = true;
  postPatch = ''
    export OMP_NUM_THREADS=$NIX_BUILD_CORES
  '';
  enableParallelBuilding = true;
  dependencies = [ numpy scipy ];
  build-system = [ setuptools cython ];
  nativeCheckInputs = [ pytestCheckHook ];
}
