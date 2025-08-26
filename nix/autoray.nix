{ buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, numpy
, scipy
, hatchling
, hatch-vcs
}:

buildPythonPackage rec {
  pname = "autoray";
  version = "0.7.2";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "jcmgray";
    repo = "autoray";
    tag = "v${version}";
    hash = "sha256-2e4lpvSkKN2s8HIyyLdqlUsTbaVHNR9DM5VBe05XPdk";
  };
  nativeBuildInputs = [ hatchling hatch-vcs ];
  nativeCheckInputs = [ numpy scipy pytestCheckHook ];
}
