class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.6.0/fpm-0.6.0.zip"
  sha256 "365516f66b116a112746af043e8eccb3d854d6feb1fad0507c570433dacbf7be"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.6.0"
    sha256 cellar: :any, big_sur:  "78f938d22b0c3e9dc47424d439c9c2c35d31cd8b0a56da3ad314e62d18d792a5"
    sha256 cellar: :any, catalina: "d58408b7c69a5e4abfe5071b05255c1a58a8a39b5d023313b8394401fbb7f78c"
  end

  depends_on "curl" => :build
  depends_on "gcc" # for gfortran
  fails_with gcc: "4"
  fails_with gcc: "5"
  fails_with gcc: "6"
  fails_with :clang

  def install
    ENV.fortran
    system "./install.sh", "--prefix=#{prefix}"
  end

  test do
    system "#{bin}/fpm", "--version"
  end
end
