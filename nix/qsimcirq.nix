{ lib
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
, cmake
, which
}:

buildPythonPackage {
  pname = "qsimcirq";
  version = "0.21.0";
  format = "setuptools";
  stdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "qsim";
    tag = "v0.21.0";
    hash = "sha256-GqUUA3In/euG9KVBKVvapblSlYB6GBYJX8O80cu7vm4=";
  };
  dontUseCmakeConfigure = true;
  dependencies = [ absl-py cirq-core numpy typing-extensions ];
  buildInputs = [ pybind11 ] ++ lib.optionals cudaSupport [ cudaPackages.cuda_cudart cudaPackages.cuda_cccl cudaPackages.libcublas ];
  nativeBuildInputs = [ setuptools cmake ] ++ lib.optionals cudaSupport [ which cudaPackages.cuda_nvcc ];
  meta = with lib; {
    description = "Schrödinger and Schrödinger-Feynman simulators for quantum circuits.";
    homepage = "https://quantumai.google/qsim";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ twesterhout ];
  };
} // lib.optionalAttrs cudaSupport {
  CUDAARCHS = cudaPackages.flags.cmakeCudaArchitecturesString;
  CUQUANTUM_ROOT = "${custatevec}/lib/${python.libPrefix}/site-packages/cuquantum";
}
