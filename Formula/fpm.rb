class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.5.0/fpm-0.5.0.zip"
  sha256 "e4a06956d2300f9aa1d06bd3323670480e946549617582e32684ded6921a921e"
  license "MIT"

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.5.0"
    sha256 cellar: :any, big_sur:  "e8f5393d340e4c4230c8ce207069ccb4d797868b7e38a9ebe77c4084dad6e53c"
    sha256 cellar: :any, catalina: "9d6174df624b83d6b878ab1352d19c68dc0bc3e70c12cfb7927151dc7997e52b"
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
