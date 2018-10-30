require "language/node"

class Alexjs < Formula
  desc "Catch insensitive, inconsiderate writing"
  homepage "https://alexjs.com"
  url "https://github.com/get-alex/alex/archive/6.0.1.tar.gz"
  sha256 "8a8539e08111287ae9fc1e5c7e50e686cb4c4616820efe207772543ad58d7854"

  bottle do
    cellar :any_skip_relocation
    sha256 "8e2108b653293d18ab50c95597f16cfd13029883e783b8114d2944933583f979" => :mojave
    sha256 "6a3613906ada284c99b6a0dbbd486446ba1cb2ee07786139ef1da8d8889b1352" => :high_sierra
    sha256 "858ac6fdcf4d13ee13580f6e9d6ba653e0809fb1ed5298e3b06a64976faabac0" => :sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.txt").write "garbageman"
    assert_match "garbage collector", shell_output("#{bin}/alex test.txt 2>&1", 1)
  end
end
