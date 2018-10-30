require "language/node"
require "json"

class Babel < Formula
  desc "Compiler for writing next generation JavaScript"
  homepage "https://babeljs.io/"
  url "https://registry.npmjs.org/@babel/cli/-/cli-7.1.2.tgz"
  sha256 "5718cca05492c71fe852ff61aae54e1dac0d15080d92c36e4fbbba1f5898b488"

  bottle do
    sha256 "7c206f31b3a50e2adc07ba88267aed5424e0bd528393a8703c6e8ed5ef115e36" => :mojave
    sha256 "289d451d748f14b88d77d356c788b91b0217c278bcd1604d13df733060004046" => :high_sierra
    sha256 "8057b89a447b5f3bec8c8d4f3187097c85e66f468f3d010b7ae56043fbf5e983" => :sierra
  end

  depends_on "node"

  resource "babel-core" do
    url "https://registry.npmjs.org/@babel/core/-/core-7.1.2.tgz"
    sha256 "d36c13e52c343412628cbc60d8c1036868e0deba361a5f11f5bac15e9464c46a"
  end

  def install
    (buildpath/"node_modules/@babel/core").install resource("babel-core")

    # declare babel-core as a bundledDependency of babel-cli
    pkg_json = JSON.parse(IO.read("package.json"))
    pkg_json["dependencies"]["@babel/core"] = resource("babel-core").version
    pkg_json["bundledDependencies"] = ["@babel/core"]
    IO.write("package.json", JSON.pretty_generate(pkg_json))

    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"script.js").write <<~EOS
      [1,2,3].map(n => n + 1);
    EOS

    system bin/"babel", "script.js", "--out-file", "script-compiled.js"
    assert_predicate testpath/"script-compiled.js", :exist?, "script-compiled.js was not generated"

    assert_equal version, resource("babel-core").version
  end
end
