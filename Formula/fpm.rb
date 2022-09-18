class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.6.0/fpm-0.6.0.zip"
  sha256 "365516f66b116a112746af043e8eccb3d854d6feb1fad0507c570433dacbf7be"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.6.0_1"
    sha256 cellar: :any, monterey: "e7dd3da88e6823a2056a8f2f705c00d96b996fea331e16d4dbd42e365736a36e"
    sha256 cellar: :any, big_sur:  "be32d0318c31dd6e759347804a7c40ae075599f25b0fcc3b663afd6c9852faeb"
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
