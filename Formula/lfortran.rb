class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://github.com/lfortran/lfortran/releases/download/v0.67.0/lfortran-0.67.0.tar.gz"
  sha256 "d9d9fa328c396e31707896cc1e2a4f80ffc70227ed7662b961a86c8c91547381"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.67.0"
    sha256 cellar: :any, arm64_tahoe:   "75d9a026b12141f0317eb6f8852c2ba7d1f6abc18e34c9052bf47d53015fc140"
    sha256 cellar: :any, arm64_sequoia: "b7a704da818ac2ad2347b45ec2d3a36bc5574a2b738d17019c4b83736965b0b7"
    sha256 cellar: :any, arm64_linux:   "7e16e6e7f1b88b085ee7d81722def76ce91a8c81f255745511a5e58ac7e41547"
    sha256 cellar: :any, x86_64_linux:  "79f2c669940efbd27c3bc3a8710e27ea28f4577b19763d4b7ee27c1659d97ed9"
  end

  depends_on "cmake" => :build
  depends_on "lld" => :build
  depends_on "ninja" => :build
  depends_on "llvm"
  depends_on "z3"
  depends_on "zlib"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_CXX_FLAGS_RELEASE=-O3 -funroll-loops -DNDEBUG"
    cmake_args << "-DWITH_LLVM=ON"
    cmake_args << "-DWITH_LSP=yes"
    if OS.linux? && Hardware::CPU.intel?
      cmake_args << "-DCMAKE_C_FLAGS=-fuse-ld=lld"
      cmake_args << "-DCMAKE_CXX_FLAGS=-fuse-ld=lld"
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
