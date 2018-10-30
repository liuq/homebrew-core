class Openvdb < Formula
  desc "Sparse volume processing toolkit"
  homepage "http://www.openvdb.org/"
  url "https://github.com/dreamworksanimation/openvdb/archive/v5.2.0.tar.gz"
  sha256 "86b3bc51002bc25ae8d69991228228c79b040cb1a5803d87543b407645f6ab20"
  revision 1
  head "https://github.com/dreamworksanimation/openvdb.git"

  bottle do
    sha256 "8a4a4c65328e9d303e174c89a89cd7a838fe51eb30376a76523f95c1b3275918" => :mojave
    sha256 "05deec4062038c7274fbf9f4bb7565818fa4d8a922ff7e2af5dc6f7639004342" => :high_sierra
    sha256 "021270661f0d57dd6b5dac9660cedf5f239b12b55b9781a8e2c952b6a3dd854d" => :sierra
  end

  option "with-glfw", "Installs the command-line tool to view OpenVDB files"

  deprecated_option "with-viewer" => "with-glfw"

  depends_on "doxygen" => :build
  depends_on "boost"
  depends_on "c-blosc"
  depends_on "ilmbase"
  depends_on "jemalloc"
  depends_on "openexr"
  depends_on "tbb"
  depends_on "glfw" => :optional

  resource "test_file" do
    url "http://www.openvdb.org/download/models/cube.vdb.zip"
    sha256 "05476e84e91c0214ad7593850e6e7c28f777aa4ff0a1d88d91168a7dd050f922"
  end

  needs :cxx11

  def install
    ENV.cxx11
    # Adjust hard coded paths in Makefile
    args = [
      "DESTDIR=#{prefix}",
      "BLOSC_INCL_DIR=#{Formula["c-blosc"].opt_include}",
      "BLOSC_LIB_DIR=#{Formula["c-blosc"].opt_lib}",
      "BOOST_INCL_DIR=#{Formula["boost"].opt_include}",
      "BOOST_LIB_DIR=#{Formula["boost"].opt_lib}",
      "BOOST_THREAD_LIB=-lboost_thread-mt",
      "CONCURRENT_MALLOC_LIB_DIR=#{Formula["jemalloc"].opt_lib}",
      "CPPUNIT_INCL_DIR=", # Do not use cppunit
      "CPPUNIT_LIB_DIR=",
      "DOXYGEN=doxygen",
      "EXR_INCL_DIR=#{Formula["openexr"].opt_include}/OpenEXR",
      "EXR_LIB_DIR=#{Formula["openexr"].opt_lib}",
      "LOG4CPLUS_INCL_DIR=", # Do not use log4cplus
      "LOG4CPLUS_LIB_DIR=",
      "NUMPY_INCL_DIR=",
      "PYTHON_VERSION=",
      "TBB_INCL_DIR=#{Formula["tbb"].opt_include}",
      "TBB_LIB_DIR=#{Formula["tbb"].opt_lib}",
    ]

    if build.with? "glfw"
      args << "GLFW_INCL_DIR=#{Formula["glfw"].opt_include}"
      args << "GLFW_LIB_DIR=#{Formula["glfw"].opt_lib}"
      args << "GLFW_LIB=-lglfw"
    else
      args << "GLFW_INCL_DIR="
      args << "GLFW_LIB_DIR="
      args << "GLFW_LIB="
    end

    ENV.append_to_cflags "-I #{buildpath}"

    cd "openvdb" do
      system "make", "install", *args
    end
  end

  test do
    resource("test_file").stage testpath
    system "#{bin}/vdb_print", "-m", "cube.vdb"
  end
end
