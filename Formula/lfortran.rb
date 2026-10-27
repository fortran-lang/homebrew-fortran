class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://github.com/lfortran/lfortran/releases/download/v0.68.0/lfortran-0.68.0.tar.gz"
  sha256 "0fdb58f9e0f442530b274d001c7fcdf53a62ee65fa87b7ca26b96c56dd3c7d64"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.68.0_1"
    sha256 cellar: :any, arm64_tahoe:   "3e18d3b508d2633a5ee125f7d68bc5364774cc996a4feba77307922a86d3cff7"
    sha256 cellar: :any, arm64_sequoia: "da75176a6d7d13528c70eeaf14a6f1044b365e9e530514f3ae0c5002a2d4b442"
    sha256 cellar: :any, arm64_linux:   "d5a59f93a8b51646afb2febd51b30b315027c61f2190a10e132fbd84a7d0bc0c"
    sha256 cellar: :any, x86_64_linux:  "5dec6600b1597b925d9fc51646608abcee7f7a37b6cbff87ac5cb9e27d0a6ee2"
  end

  depends_on "cmake" => :build
  depends_on "emscripten" => :build
  depends_on "lld" => :build
  depends_on "ninja" => :build
  depends_on "node" => :build
  depends_on "python@3.14" => :build
  depends_on "llvm"
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
    # LLVM's static libraries drag in an unused libz3; don't record the load.
    cmake_args << "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-dead_strip_dylibs" if OS.mac?
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
