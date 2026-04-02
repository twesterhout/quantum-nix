{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  addDriverRunpath,
  autoPatchelfHook,
  pypaInstallHook,
  wheelUnpackHook,
  cudaPackages,
  python,
  jaxlib,
}:
let
  inherit (jaxlib) version;
  cudaLibPath = lib.makeLibraryPath (
    with cudaPackages;
    [
      (lib.getLib libcublas) # libcublas.so
      (lib.getLib cuda_cupti) # libcupti.so
      (lib.getLib cuda_cudart) # libcudart.so
      (lib.getLib cudnn) # libcudnn.so
      (lib.getLib libcufft) # libcufft.so
      (lib.getLib libcusolver) # libcusolver.so
      (lib.getLib libcusparse) # libcusparse.so
      (lib.getLib nccl) # libnccl.so
      (lib.getLib libnvjitlink) # libnvJitLink.so
      (lib.getLib addDriverRunpath.driverLink) # libcuda.so
    ]);
in
buildPythonPackage (finalAttrs: {
  pname = "jax-cuda13-pjrt";
  inherit version;
  pyproject = false;
  src = fetchPypi {
    pname = "jax_cuda13_pjrt";
    inherit version;
    format = "wheel";
    python = "py3";
    dist = "py3";
    platform = "manylinux_2_27_x86_64";
    hash = "sha256-sbBFXPa9qjruUTBKZWtYY4nmECstdB+lTM0SSomau30";
  };
  nativeBuildInputs = [ autoPatchelfHook pypaInstallHook wheelUnpackHook ];
  postInstall = ''
    mkdir -p $out/${python.sitePackages}/jax_plugins/nvidia/cuda_nvcc/bin
    ln -s ${lib.getExe' cudaPackages.cuda_nvcc "ptxas"} $out/${python.sitePackages}/jax_plugins/nvidia/cuda_nvcc/bin/ptxas
    ln -s ${lib.getExe' cudaPackages.cuda_nvcc "nvlink"} $out/${python.sitePackages}/jax_plugins/nvidia/cuda_nvcc/bin/nvlink
    ln -s ${cudaPackages.cuda_nvcc}/nvvm $out/${python.sitePackages}/jax_plugins/nvidia/cuda_nvcc/nvvm
  '';
  preInstallCheck = ''
    patchelf --add-rpath "${cudaLibPath}" $out/${python.sitePackages}/jax_plugins/xla_cuda13/xla_cuda_plugin.so
  '';
  doCheck = true;
  pythonImportsCheck = [ "jax_plugins" ];
  inherit cudaLibPath;
  meta = {
    description = "JAX XLA PJRT Plugin for NVIDIA GPUs";
    homepage = "https://github.com/jax-ml/jax/tree/main/jax_plugins/cuda";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.linux;
    # see CUDA compatibility matrix
    # https://jax.readthedocs.io/en/latest/installation.html#pip-installation-nvidia-gpu-cuda-installed-locally-harder
    broken = !(lib.versionAtLeast cudaPackages.cudnn.version "9.1");
  };
})
