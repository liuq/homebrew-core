class Diceware < Formula
  include Language::Python::Virtualenv

  desc "Passphrases to remember"
  homepage "https://github.com/ulif/diceware"
  url "https://github.com/ulif/diceware/archive/v0.9.5.tar.gz"
  sha256 "70c5884eed7f9d55204075cc8816ef7259000a0548f930a98d51132eef5c90ad"

  bottle do
    cellar :any_skip_relocation
    sha256 "f17a7034c6bd69b188c16dc4ad98e493dcaba45372831631fdee1e6443b244cc" => :mojave
    sha256 "804dedba249ec07880d46de1c438ab1e030dcabbd3c3a856376421c365fc2355" => :high_sierra
    sha256 "d6a2b39814cd36908c198fff005f449c5acda91b7b4416e8e670348bee83aaf1" => :sierra
    sha256 "5f0aeaaeecf438f4d61a8cdf4420198f167d49bf962dbde55e2bd8abc305dd63" => :el_capitan
  end

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match(/(\w+)(\-(\w+)){5}/, shell_output("#{bin}/diceware -d-"))
  end
end
