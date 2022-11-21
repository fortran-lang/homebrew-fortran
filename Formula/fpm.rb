class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.7.0/fpm-0.7.0.zip"
  sha256 "536dec7d4502221734683b15e6ff64a6ab3f9910df122d18f851c9a68711f91f"
  license "MIT"

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.7.0"
    sha256 cellar: :any, monterey: "108def5ea47566a982c910ef0b1c893df85797685cf8264336d2799c813905f4"
    sha256 cellar: :any, big_sur:  "53f38db60b36ba6e21637b6ba15d92040d807a26c517e264a8025eb24109d662"
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
