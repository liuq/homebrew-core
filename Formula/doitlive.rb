class Doitlive < Formula
  desc "Replay stored shell commands for live presentations"
  homepage "https://doitlive.readthedocs.io/en/latest/"
  url "https://files.pythonhosted.org/packages/22/3e/58dd3cfb662f4729fb45ecc16fc0dbbfc8e8ef51600f174938c2a8b26c62/doitlive-4.1.0.tar.gz"
  sha256 "9f138d4100a5f83e85bbc08a0b26beff2368fbb50a511cb17fe03765b6ad7b7e"

  bottle do
    cellar :any_skip_relocation
    sha256 "b2efb2513c4052698e5de3fc5e35fbf8fd9be4a83b76e2ac0674a99163233aa1" => :mojave
    sha256 "5cb97d9659b4b98b91412a75b1ea332f4b9e654f522cf017200011373728486f" => :high_sierra
    sha256 "126ad73dbc3085f9cf18b7c118b59c8c0d98bb93fcb129d9c4c1d5cd38bd7a10" => :sierra
  end

  depends_on "python"

  def install
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system "python3", "setup.py", "install", "--prefix=#{libexec}"

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])

    output = Utils.popen_read("SHELL=bash #{libexec}/bin/doitlive completion")
    (bash_completion/"doitlive").write output

    output = Utils.popen_read("SHELL=zsh #{libexec}/bin/doitlive completion")
    (zsh_completion/"_doitlive").write output
  end

  test do
    system "#{bin}/doitlive", "themes", "--preview"
  end
end
