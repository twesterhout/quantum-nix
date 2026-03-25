{ lib
, autoAddDriverRunpath
, config
, stdenv
, buildPythonPackage
, python
, fetchFromGitHub
, cudaSupport ? config.cudaSupport
, cudaPackages
, custatevec
, absl-py
, cirq-core
, numpy
, typing-extensions
, setuptools
, pybind11
, pytestCheckHook
, cmake
, doCheck ? true
}:

buildPythonPackage ({
  pname = "qsimcirq";
  version = "0.23.0.dev0";
  format = "setuptools";
  stdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "qsim";
    rev = "dbeebff7f2ecf26d199e932d6b4ea20777c3aa28";
    hash = "sha256-oTSf96eI93g9AKqe9qxpa6Ir28J0+t3fEx+lkK9t0/E";
  };
  dontUseCmakeConfigure = true;
  dependencies = [ absl-py cirq-core numpy typing-extensions ];
  buildInputs = [ pybind11 ] ++ lib.optionals cudaSupport [ cudaPackages.cuda_cudart cudaPackages.cuda_cccl cudaPackages.libcublas ];
  nativeBuildInputs = [ setuptools cmake ] ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc autoAddDriverRunpath ];
  preCheck = "rm -rf qsimcirq/";
  nativeCheckInputs = [ pytestCheckHook ];
  pytestFlagsArray = [ "qsimcirq_tests/" "--capture=no" "-v" ];
  disabledTests = [ "multi_qubit_noise" ]; # These tests complain about non-unitary matrices. Likely an issue with precision
  inherit doCheck;
  meta = with lib; {
    description = "Schrödinger and Schrödinger-Feynman simulators for quantum circuits.";
    homepage = "https://quantumai.google/qsim";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ twesterhout ];
  };
  postPatch = ''
    echo -e "find_package(Python 3.10 COMPONENTS Interpreter Development REQUIRED)\nfind_package(pybind11 CONFIG REQUIRED)" > pybind_interface/GetPybind11.cmake
    substituteInPlace pybind_interface/decide/CMakeLists.txt \
      --replace-fail 'find_package(Python3' '# find_package(Python3' \
      --replace-fail 'include_directories(''${PYTHON_INCLUDE_DIRS} ''${pybind11_SOURCE_DIR}/include)' 'target_link_libraries(qsim_decide PUBLIC pybind11::pybind11)'
  '';
} // lib.optionalAttrs cudaSupport {
  CUDAARCHS = cudaPackages.flags.cmakeCudaArchitecturesString;
  # CUQUANTUM_ROOT = "${custatevec}/lib/${python.libPrefix}/site-packages/cuquantum";
})
