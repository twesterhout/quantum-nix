{ buildPythonPackage
, fetchFromGitHub
, python
, numpy
, scipy
, gmpy2
, boost
, setuptools
, cython
}:

buildPythonPackage {
  pname = "quspin-extensions";
  version = "0.1.6";
  src = fetchFromGitHub {
    owner = "QuSpin";
    repo = "quspin-extensions";
    rev = "c27603d7c6c3ffe39c8cf31e1a053fe22d35a313";
    hash = "sha256-cqFWz/4kB+X/QS/lrEg8MHWpCJBCwzY8YX2rwqXgI0A=";
  };
  # We need setuptools for the --parallel flag; without it the build takes ages
  format = "setuptools";
  enableParallelBuilding = true;
  postPatch = ''
    export BOOST_ROOT=${boost}
    appendToVar setupPyBuildFlags --parallel "$NIX_BUILD_CORES"
  '';
  dependencies = [ numpy scipy gmpy2 ];
  buildInputs = [ boost ];
  build-system = [ setuptools cython ];
}
