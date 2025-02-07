{ lib
, buildPythonPackage
, fetchFromGitHub
, python
, quspin-extensions
, parallel-sparse-tools
, numpy
, scipy
, dill
, matplotlib
, numexpr
, numba
, six
, joblib
, pdm-backend
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "quspin";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "QuSpin";
    repo = "QuSpin";
    rev = "v${version}";
    hash = "sha256-Etu45rhkeLMsWObasJoFL0AFLQ+o7fC4Lg1msSntLKA=";
  };
  postPatch = ''
    export OMP_NUM_THREADS=$NIX_BUILD_CORES
  '';
  setupPyGlobalFlags = [ "--omp" ];
  pyproject = true;
  dependencies = [
    quspin-extensions
    parallel-sparse-tools
    numpy
    dill
    scipy
    matplotlib
    numexpr
    numba
    six
    joblib
  ];
  # Disable tests that are taking too long
  disabledTests = [ "test_project_from_spin" "test_general_spin_opstr" ];
  pytestFlagsArray = [
    "test/"
    "--durations=0"
    "--deselect test/test_hamiltonian.py::test_evolve"
    "--deselect test/test_Floquet.py::test_mcmc"
  ];
  build-system = [ pdm-backend ];
  nativeCheckInputs = [ pytestCheckHook ];
}
