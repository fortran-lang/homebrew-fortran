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
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.66.0_1"
    sha256 cellar: :any, arm64_tahoe:   "f6fe5da65902ad0fea0f8a9c5619df2d7db1c35aea50b00e6e94e804e6849d09"
    sha256 cellar: :any, arm64_sequoia: "799520e2a1afcc744d9f992bc5554d91dd4329a7ba77b4a3cd0c4ee6fbb4ad5c"
    sha256 cellar: :any, arm64_linux:   "c51fd048cb258dcd90283ff1d5bb9bd842803726f6cbd7fce75ce35db0a1c3c0"
    sha256 cellar: :any, x86_64_linux:  "c64aa78f02c7a53d3e7bf9caf7e826ffe9f9c5ad50718f4f6c3fd72b30e7ae14"
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
