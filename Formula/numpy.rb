class Numpy < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/83/6b/d03277eacf113697675cd659086a4dcf9472108e2f1a83884c0271bdca46/numpy-1.15.3.zip"
  sha256 "1c0c80e74759fa4942298044274f2c11b08c86230b25b8b819e55e644f5ff2b6"

  bottle do
    sha256 "f09037da31fe744c79455c27993b0496e638e9e817bd1a1d6b1bd7f750b7dfcc" => :mojave
    sha256 "c8b98a056e29916cfe172acb5426734ed136486e31476b5e932353341dbf8de8" => :high_sierra
    sha256 "6c49d36ada8d285b711a108b0d5a7547abdc0374448437b40f508f502430d6d0" => :sierra
  end

  head do
    url "https://github.com/numpy/numpy.git"

    resource "Cython" do
      url "https://files.pythonhosted.org/packages/f0/66/6309291b19b498b672817bd237caec787d1b18013ee659f17b1ec5844887/Cython-0.29.tar.gz"
      sha256 "94916d1ede67682638d3cc0feb10648ff14dc51fb7a7f147f4fedce78eaaea97"
    end
  end

  option "without-python@2", "Build without python2 support"

  depends_on "gcc" => :build # for gfortran
  depends_on "openblas"
  depends_on "python" => :recommended
  depends_on "python@2" => :recommended

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath

      nose_path = libexec/"nose/lib/python#{version}/site-packages"
      resource("nose").stage do
        system python, *Language::Python.setup_install_args(libexec/"nose")
        (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
      end

      if build.head?
        ENV.prepend_create_path "PYTHONPATH", buildpath/"tools/lib/python#{version}/site-packages"
        resource("Cython").stage do
          system python, *Language::Python.setup_install_args(buildpath/"tools")
        end
      end

      system python, "setup.py",
        "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
        "install", "--prefix=#{prefix}",
        "--single-version-externally-managed", "--record=installed.txt"
    end
  end

  def caveats
    if build.with?("python@2") && !Formula["python@2"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<~EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", <<~EOS
        import numpy as np
        t = np.ones((3,3), int)
        assert t.sum() == 9
        assert np.dot(t, t).sum() == 27
      EOS
    end
  end
end
