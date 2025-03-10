# Formula last updated on 2025-03-10T12:46:39Z (Run: 13765004122-9)
# Formula last updated on 2025-03-10

class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.11.0/fpm-0.11.0.zip"
  sha256 "f6c998c9afd39eb42c7e80a306cfbed5faa77eaa42eb4f75b93864c338db1795"
  license "MIT"

  bottle do
    root_url "https://github.com/fortran-lang/fpm/releases/download/v0.11.0/fpm-0.11.0.zip"
    sha256 cellar: :any, ventura:  "2a7b23338d5b3fedad1b09d5b77714e7a54ac9966039516f0f38d7446c212ffd"
    sha256 cellar: :any, monterey: "902d30ac0a3227e78d98d609fb847cc2e1bad4f772f5c18cdd62b06e1fa49242"
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
