{ lib
, stdenv
, cmake
, fetchFromGitHub
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "hptt";
  version = "1.0.5";
  src = fetchFromGitHub {
    owner = "springer13";
    repo = pname;
    rev = "942538649b51ff14403a0c73a35d9825eab2d7de";
    hash = "sha256-2/KFE7FDuHc+ss7spq8fMnqeLCG9ni/oRcNa9DcWUhU=";
  };
  patches = [
    # (fetchpatch {
    #   name = "enable-cmake-based-testing.patch";
    #   url = "https://github.com/springer13/hptt/pull/28/commits/93ed8592f21a868fe89a4de06f65d2ae7d095bd4.patch";
    #   hash = "sha256-P0+W+AvksLiWVOSTU18Wyyn9jKkabbaPjElvzmyiTSs=";
    # })
    (fetchpatch {
      name = "fix-std-conj-usage.patch";
      url = "https://github.com/springer13/hptt/pull/32/commits/beee8f1cb321b273d4ef11ac943c9cff3f5b0ce2.patch";
      hash = "sha256-pK7EGuqvppEvLctImAPOCSGuEY1YYvXArLIjl+K4Lgk=";
    })
  ];
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'STATIC' 'SHARED' --replace-fail '-fopenmp' ' ' --replace-fail '-march=native' ' ' --replace-fail '-mtune=native' ' '
    cat >>CMakeLists.txt <<-EOF
      find_package(OpenMP REQUIRED)
      target_link_libraries(hptt PRIVATE OpenMP::OpenMP_CXX)
    EOF
  '';
  nativeBuildInputs = [ cmake ];
  cmakeArgs = [ "-DENABLE_AVX=ON" "-DBUILD_SHARED_LIBS=ON" ];
  enableParallelBuilding = true;
  meta = with lib; {
    description = "High-Performance Tensor Transpose library";
    homepage = "https://github.com/springer13/hptt";
    license = licenses.bsd3;
    maintainers = with maintainers; [ twesterhout ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
