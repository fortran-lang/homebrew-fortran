class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://lfortran.github.io/tarballs/release/lfortran-0.15.0.tar.gz"
  sha256 "8712c1b0c886f08937ff4c277ff3fa5c05e4dead1bafe55e3bd789be96470127"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.14.0"
    sha256 cellar: :any, big_sur:  "2271bb78f53ee81be48159b4d3db86d24806302e9643c772c9f09c1ac08f3b30"
    sha256 cellar: :any, catalina: "df59995bcf1c0d45cdcff3a99fee301fc530193693c9c4cf3c0b94cceffe924c"
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
