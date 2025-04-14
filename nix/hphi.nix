{ lib
, stdenv
, gfortran
, fetchFromGitHub
, mpich
# , openblas
, blas
, lapack
, cmake
, ninja
, python3
, mpiSupport ? false
, doCheck ? true
}:
assert !blas.isILP64;

stdenv.mkDerivation (finalAttrs: {
  pname = "HPhi";
  version = "3.5.2";
  src = fetchFromGitHub {
    owner = "issp-center-dev";
    repo = "HPhi";
    tag = "v3.5.2";
    hash = "sha256-3U95bVdCNCXWYNsYgCao+665b8wlEa8FV6jfPdtuyB0=";
  };

  src-StdFace = fetchFromGitHub {
    owner = "issp-center-dev";
    repo = "StdFace";
    tag = "v0.5";
    hash = "sha256-Nx2/6Hnel6fVqWeLfI01V0U8MaIDVWicbHdBIEiuvDo=";
  };

  postPatch = ''
    mkdir -p src/StdFace
    cp -R --no-preserve=mode,ownership ${finalAttrs.src-StdFace}/* ./src/StdFace/
  '';

  inherit doCheck;
  checkPhase = ''
    CTEST_PARALLEL_LEVEL=1 OMP_NUM_THREADS=$NIX_BUILD_CORES ninja test
  '';

  buildInputs = [ blas lapack ] ++ lib.optionals mpiSupport [ mpich ];
  cmakeArgs = [
    "-GNinja"
    (lib.cmakeBool "ENABLE_MPI" mpiSupport)
    "-DUSE_SCALAPACK=OFF"
    "-DGIT_SUBMODULE_UPDATE=OFF"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    (python3.withPackages (ps: with ps; [ numpy ]))
    gfortran
  ];

  meta = {
    description = "Quantum Lattice Model Simulator Package";
    homepage = "https://www.pasums.issp.u-tokyo.ac.jp/hphi/en/";
  };
})
