{ buildPythonPackage
, fetchPypi
, fetchFromGitHub
, numpy
, setuptools
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
  dependencies = [ numpy ];
  nativeBuildInputs = [ setuptools ];
}
