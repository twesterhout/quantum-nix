{ buildPythonPackage
, fetchPypi
, fetchFromGitHub
, numpy
, pandas
, setuptools
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "uniplot";
  version = "2025.04.14-unstable";
  format = "pyproject";
  # src = fetchPypi {
  #   inherit version pname;
  #   hash = "sha256-lFsam7q4e/1A0zZMnwFH0LMf7dB1JRZ43HWl/ZsCGlg=";
  # };
  src = fetchFromGitHub {
    owner = "olavolav";
    repo = pname;
    rev = "618363fa9d065ca837d29e97d8352c84ead23e5d";
    hash = "sha256-esjcJSUJ2Nws53VbR0j55HkKuok3o4vkY7kw3UIMW5U=";
  };
  postPatch = ''
    echo "from setuptools import setup, find_packages; setup(packages=find_packages())" >> setup.py
  '';
  dependencies = [ numpy ];
  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pandas pytestCheckHook ];
  disabledTestPaths = [
    "tests/acceptance/test_with_polars.py"
    "tests/acceptance/test_performance.py"
  ];
}
