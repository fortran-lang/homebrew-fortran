class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.8.1/fpm-0.8.1.zip"
  sha256 "0bd978bb1d3f2a3297d82a0d6ac009746a466cfa9a59ba3b6513b74e5ce4b7bf"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.8.1_1"
    sha256 cellar: :any, ventura:  "bf09e4ab59087d90953d54ba63765117379a01c44c09b067018cd3ba8ee258de"
    sha256 cellar: :any, monterey: "438a72f03ab002b16e71ceac84d77f1d653ea1262e8a497a988b169720553f0a"
  end

  depends_on "curl" => :build
  depends_on "gcc" # for gfortran
  fails_with gcc: "4"
  fails_with gcc: "5"
  fails_with gcc: "6"
  fails_with gcc: "7"
  fails_with gcc: "8"
  fails_with gcc: "9"
  fails_with :clang

  def install
    ENV.fortran
    `export HOMEBREW_NO_INSTALL_FROM_API=1`
    `chmod a+x ./install.sh`
    system "./install.sh", "--prefix=#{prefix}"
  end

  test do
    system "#{bin}/fpm", "--version"
  end
end
