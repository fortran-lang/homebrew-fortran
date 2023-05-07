class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.8.1/fpm-0.8.1.zip"
  sha256 "0bd978bb1d3f2a3297d82a0d6ac009746a466cfa9a59ba3b6513b74e5ce4b7bf"
  license "MIT"

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.8.1"
    sha256 cellar: :any, ventura:  "8d2cc3dea7e1fd64f760814c2cee235af3ae196747a76817c375421b5022dc81"
    sha256 cellar: :any, monterey: "d9faf79766a21dba27c009c335a2ab8b65dc6e3b8131c8953d7d27d240945232"
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
