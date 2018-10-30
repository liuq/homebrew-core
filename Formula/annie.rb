class Annie < Formula
  desc "Fast, simple and clean video downloader"
  homepage "https://github.com/iawia002/annie"
  url "https://github.com/iawia002/annie/archive/0.8.2.tar.gz"
  sha256 "9fdaedb1ee6ec0b677471c05013c3516628278f6a5a27156c08ce6e56fc60806"

  bottle do
    cellar :any_skip_relocation
    sha256 "bb4f491445c50f4101e97148976258a9bac4d699d757d9a37d206b01b45a6fcc" => :mojave
    sha256 "f4b4ec64ed17c988dbda9a468239145aa98e84287db6755b0e6cfe17e7f79232" => :high_sierra
    sha256 "badbb3d077638908cf851f7b785614173118d16cc97ae4bae526e6d1ec40ac84" => :sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/iawia002/annie").install buildpath.children
    cd "src/github.com/iawia002/annie" do
      system "go", "build", "-o", bin/"annie"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"annie", "-i", "https://www.bilibili.com/video/av20203945"
  end
end
