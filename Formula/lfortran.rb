class Lfortran < Formula
  desc "Modern interactive LLVM-based Fortran compiler"
  homepage "https://lfortran.org"
  url "https://github.com/lfortran/lfortran/releases/download/v0.68.0/lfortran-0.68.0.tar.gz"
  sha256 "0fdb58f9e0f442530b274d001c7fcdf53a62ee65fa87b7ca26b96c56dd3c7d64"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/lfortran-0.68.0"
    sha256 cellar: :any, arm64_tahoe:   "50c3a674e912f82ce4b5e854a6bf06954a677b43a2a735e9391bdc1b7f73322b"
    sha256 cellar: :any, arm64_sequoia: "98f7f5fb07b88ef013c3d20322eb0923fad6a2c1a7be285450bc131b5beb6f10"
    sha256 cellar: :any, arm64_linux:   "e82af167a2ceae11e88790cb4b79914886f9b59cb389f63f5ae9ae8013d224d2"
    sha256 cellar: :any, x86_64_linux:  "c146a77174a7437866be01005c25074e8a22d686a18760ce3721eef5593ef4b4"
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
