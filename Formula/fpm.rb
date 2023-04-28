class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.8.1/fpm-0.8.1.zip"
  sha256 "0bd978bb1d3f2a3297d82a0d6ac009746a466cfa9a59ba3b6513b74e5ce4b7bf"
  license "MIT"

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
    system "sh ./install.sh --prefix=#{prefix}"
  end

  test do
    system "#{bin}/fpm", "--version"
  end
end
