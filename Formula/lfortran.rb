class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://github.com/lfortran/lfortran/releases/download/v0.67.0/lfortran-0.67.0.tar.gz"
  sha256 "d9d9fa328c396e31707896cc1e2a4f80ffc70227ed7662b961a86c8c91547381"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.67.0_1"
    sha256 cellar: :any, arm64_tahoe:   "dc4cf074b16f3782b6de05ed540a995fe0bd8308868f43bef7a54d931b86ef21"
    sha256 cellar: :any, arm64_sequoia: "e1117d9bc8fea1aa39271c1c4b7fab59585a4cc3b63d7bc208a2877e9a290f41"
    sha256 cellar: :any, arm64_linux:   "d9bd0ecf2db0d21c48b8dbbe51f24e5628563063c30050a2a6da62462d367adb"
    sha256 cellar: :any, x86_64_linux:  "30fd0e449fe3e5c43d2dfd5577ef2a096ce360b0f17fb5eb675dcb4d706161a3"
  end

  depends_on "cmake" => :build
  depends_on "emscripten" => :build
  depends_on "lld" => :build
  depends_on "ninja" => :build
  depends_on "node" => :build
  depends_on "python@3.14" => :build
  depends_on "llvm"
  depends_on "z3"
  depends_on "zlib"

  def install
    # wasm targets look for the SDK at "$EMSDK_PATH/upstream/emscripten/emcc",
    # but Homebrew's emscripten installs the SDK tree directly under libexec.
    # Link it into the expected layout; `caveats` points users at the same shim.
    (libexec/"emsdk/upstream").mkpath
    ln_s formula_opt_libexec("emscripten"), libexec/"emsdk/upstream/emscripten"
    ENV["EMSDK_PATH"] = (libexec/"emsdk").to_s
    # emcc's wrapper falls back to `command -v python3`, which is Xcode's 3.9
    # on macOS and absent on Linux under superenv; point it at our python.
    ENV["EMSDK_PYTHON"] = formula_opt_bin("python@3.14")/"python3.14"
    # emcc generates its sysroot into its cache, which lives in emscripten's
    # Cellar; the build sandbox only allows writes to our own.
    ENV["EM_CACHE"] = (buildpath/"emcache").to_s

    # superenv replaces -O3 with -Os, at which the runtime miscompiles formatted
    # reads from stdin. Without this the -O3 requested below never takes effect.
    ENV.O3

    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_CXX_FLAGS_RELEASE=-O3 -funroll-loops -DNDEBUG"
    cmake_args << "-DWITH_LLVM=ON"
    cmake_args << "-DWITH_LSP=yes"
    cmake_args << "-DWITH_TARGET_WASM=yes"
    if OS.linux? && Hardware::CPU.intel?
      cmake_args << "-DCMAKE_C_FLAGS=-fuse-ld=lld"
      cmake_args << "-DCMAKE_CXX_FLAGS=-fuse-ld=lld"
    end
    system "cmake", *cmake_args, "-G", "Ninja", "-B", "build"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      Compiling to WebAssembly needs Emscripten, which is only a build dependency:
        brew install emscripten
        export EMSDK_PATH=#{opt_libexec}/emsdk
    EOS
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

    # The driver appends this to the link line for emscripten targets.
    assert_path_exists lib/"lfortran_runtime_wasm_emcc.o"

    (testpath/"read.f90").write <<~EOS
      program read_stdin
        integer :: x
        read(*, '(I4)') x
        if (x /= 42) error stop 1
      end
    EOS

    system bin/"lfortran", testpath/"read.f90", "-o", testpath/"read_stdin"
    assert_empty pipe_output("#{testpath}/read_stdin", "4 2 \n", 0)
  end
end
