class Fpm < Formula
  desc "Fortran Package Manager (fpm)"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.9.0/fpm-0.9.0.zip"
  sha256 "484debabd7d22186ac41f865ddf63475c279a61a51aaff5636ed615860b5b8d7"
  license "MIT"

  bottle do
    root_url "https://github.com/fortran-lang/homebrew-fortran/releases/download/fpm-0.8.2"
    sha256 cellar: :any, ventura:  "c45c3d55b9666a44c9f899b467e0cd46c9ca444ddbf19acc772017f5a0db73e1"
    sha256 cellar: :any, monterey: "ed220892536f6bf52027e3b1f076fc4a4eb5440eeaa5c8f40af72188b427bf18"
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
