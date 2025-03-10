# Formula last updated on 2025-03-10 for version 0.11.0

class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.11.0/fpm-0.11.0.zip"
  sha256 "f6c998c9afd39eb42c7e80a306cfbed5faa77eaa42eb4f75b93864c338db1795"
  license "MIT"

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.11.0"
    rebuild 1
    sha256 cellar: :any, arm64_sonoma: "d5795b3b84fc2cb7eff32f48a64af03f439cd4bc562727ae2cfdde161b819f5e"
    sha256 cellar: :any, ventura:      "6046a6004ff42f03f67dff1af39f80be7e0deb679f797c787a1883e28ac10778"
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
