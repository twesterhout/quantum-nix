{ buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pyparsing
, setuptools
, setuptools_scm
}:

buildPythonPackage rec {
  pname = "pyclibrary";
  version = "0.3.0";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "MatthieuDartiailh";
    repo = "pyclibrary";
    tag = "${version}";
    hash = "sha256-RyIbRySRWSZwKP5G6yXYCOnfKOV0165aPyjMf3nSbOM";
  };
  dependencies = [ pyparsing ];
  nativeBuildInputs = [ setuptools setuptools_scm ];
  nativeCheckInputs = [ pytestCheckHook ];
}

