class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://lfortran.github.io/tarballs/release/lfortran-0.19.0.tar.gz"
  sha256 "d496f61d7133b624deb3562677c0cbf98e747262babd4ac010dbd3ab4303d805"
  license "BSD-3-Clause"
  revision 1

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.16.0"
    sha256 cellar: :any, big_sur: "67d1ee4fd768f602cd2ed2dcd26dce2b2b011edaebbb7fea0e91541d4384624e"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "llvm@11"
  depends_on "zlib"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_CXX_FLAGS_RELEASE=-O3 -funroll-loops -DNDEBUG"
    cmake_args << "-DWITH_LLVM=ON"
    system "cmake", *cmake_args, "-G", "Ninja", "-B", "build"
    system "cmake", "--build", "build"
    system "ctest", "--test-dir", "build", "--output-on-failure"
    system "cmake", "--install", "build"
  end

  test do
    system "#{bin}/lfortran", "--version"
    (testpath/"hello.f90").write <<~EOS
      program hello
        print *, "Hello, World!"
      end
    EOS
    system "#{bin}/lfortran", testpath/"hello.f90", "-o", testpath/"hello"
    assert_predicate testpath/"hello", :exist?
    system testpath/"hello"
  end
end
