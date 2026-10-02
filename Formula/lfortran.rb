class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://github.com/lfortran/lfortran/releases/download/v0.66.0/lfortran-0.66.0.tar.gz"
  sha256 "961d84f49d07951a279b7835e0f9864489a167a80a8c3c502a797fb6c61669c7"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.66.0"
    sha256 cellar: :any, arm64_tahoe:   "80889f6c5c2ec10527d6bfe616153093ac042ef799bc8e9d88b043c00a9cda11"
    sha256 cellar: :any, arm64_sequoia: "e69fa18d8537720f1e942b50c7bcf4a4f54a0584618e1792b39bbe814b00be5b"
    sha256 cellar: :any, arm64_linux:   "bd3f769f3807a94758604433ee079e04b667dbc204c457fa4395154081fe7d44"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "lld" => :build
  depends_on "llvm"
  depends_on "z3"
  depends_on "zlib"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_CXX_FLAGS_RELEASE=-O3 -funroll-loops -DNDEBUG"
    cmake_args << "-DWITH_LLVM=ON"
    cmake_args << "-DWITH_LSP=yes"
    on_linux do
      on_intel do
        cmake_args << "-DCMAKE_C_FLAGS=-fuse-ld=lld"
        cmake_args << "-DCMAKE_CXX_FLAGS=-fuse-ld=lld"
      end
    end
    system "cmake", *cmake_args, "-G", "Ninja", "-B", "build"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lfortran --version")

    (testpath/"hello.f90").write <<~EOS
      program hello
        print *, "Hello, World!"
      end
    EOS

    system bin/"lfortran", testpath/"hello.f90", "-o", testpath/"hello"
    assert_path_exists testpath/"hello"
    assert_equal "Hello, World!", shell_output("#{testpath}/hello").strip
  end
end
