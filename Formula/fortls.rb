class Fortls < Formula
  include Language::Python::Virtualenv

  desc "Fortran language server"
  homepage "https://github.com/gnikit/fortls"
  url "https://pypi.io/packages/source/f/fortls/fortls-2.13.0.tar.gz"
  sha256 "23c5013e8dd8e1d65bf07be610d0827bc48aa7331a7a7ce13612d4c646d0db31"
  license "MIT"
  head "https://github.com/gnikit/fortls.git", branch: "master"

  depends_on "python@3.10"

  resource "json5" do
    url "https://pypi.io/packages/source/j/json5/json5-0.9.5.tar.gz"
    sha256 "703cfee540790576b56a92e1c6aaa6c4b0d98971dc358ead83812aa4d06bdb96"
  end

  resource "packaging" do
    url "https://pypi.io/packages/source/p/packaging/packaging-21.3.tar.gz"
    sha256 "dd47c42927d89ab911e606518907cc2d3a1f38bbd026385970643f9c5b8ecfeb"
  end

  resource "pyparsing" do
    url "https://pypi.io/packages/source/p/pyparsing/pyparsing-3.0.9.tar.gz"
    sha256 "2b020ecf7d21b687f219b71ecad3631f644a47f01403fa1d1036b0c6416d70fb"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "#{bin}/fortls", "--help"
  end
end
