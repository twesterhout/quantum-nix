{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  pypaInstallHook,
  wheelUnpackHook,
  cudaPackages,
  python,
  jaxlib,
  jax-cuda13-pjrt,
}:
let
  inherit (jaxlib) version;
  inherit (jax-cuda13-pjrt) cudaLibPath;
  py = ''cp${lib.replaceStrings ["."] [""] python.pythonVersion}'';
in
buildPythonPackage {
  pname = "jax-cuda13-plugin";
  inherit version;
  pyproject = false;
  src = fetchPypi {
    inherit version;
    platform = "manylinux_2_27_x86_64";
    pname = "jax_cuda13_plugin";
    format = "wheel";
    dist = py;
    python = py;
    abi = py;
    hash = "sha256-AJKi74kMoRXrcT/rt662lRDJv7lu/fZd7Sk8FXZeWIE";
  };
  nativeBuildInputs = [ autoPatchelfHook pypaInstallHook wheelUnpackHook ];
  postInstall = ''
    mkdir -p $out/${python.sitePackages}/jax_cuda13_plugin/cuda/bin
    ln -s ${lib.getExe' cudaPackages.cuda_nvcc "ptxas"} $out/${python.sitePackages}/jax_cuda13_plugin/cuda/bin
    ln -s ${lib.getExe' cudaPackages.cuda_nvcc "nvlink"} $out/${python.sitePackages}/jax_cuda13_plugin/cuda/bin
  '';
  preInstallCheck = ''
    patchelf --add-rpath "${cudaLibPath}" $out/${python.sitePackages}/jax_cuda13_plugin/*.so
  '';
  dependencies = [ jax-cuda13-pjrt ];
  pythonImportsCheck = [ "jax_cuda13_plugin" ];
  # FIXME: there are no tests, but we need to run preInstallCheck above
  doCheck = true;
  meta = {
    description = "JAX Plugin for CUDA12";
    homepage = "https://github.com/jax-ml/jax/tree/main/jax_plugins/cuda";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.linux;
    # see CUDA compatibility matrix
    # https://jax.readthedocs.io/en/latest/installation.html#pip-installation-nvidia-gpu-cuda-installed-locally-harder
    broken = !(lib.versionAtLeast cudaPackages.cudnn.version "9.1");
  };
}
