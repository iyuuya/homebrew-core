class GstRtspServer < Formula
  desc "RTSP server library based on GStreamer"
  homepage "https://gstreamer.freedesktop.org/modules/gst-rtsp-server.html"
  url "https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-1.18.4.tar.xz"
  sha256 "a46bb8de40b971a048580279d2660e616796f871ad3ed00c8a95fe4d273a6c94"
  license "LGPL-2.0-or-later"

  livecheck do
    url "https://gstreamer.freedesktop.org/src/gst-rtsp-server/"
    regex(/href=.*?gst-rtsp-server[._-]v?(\d+\.\d*[02468](?:\.\d+)*)\.t/i)
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "ef58d908e4c349d21b9fc01986c09d1915b3f00c36e48d05d23637048a13b841"
    sha256 cellar: :any, big_sur:       "897354f53384202684bce2bf34017b25cb47cdb5cb59ce8ba74ad8804efe96c4"
    sha256 cellar: :any, catalina:      "36ff2dc19e36d15d80f65b0c49e4a99c2145bc241bba2057542cb686c71b7ab6"
    sha256 cellar: :any, mojave:        "39c1d8288fc58c0c56e364381fa9d2f9e7632a73fa40d5440268a69a252c7f34"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base"
  depends_on "gstreamer"

  def install
    args = std_meson_args + %w[
      -Dintrospection=enabled
      -Dexamples=disabled
      -Dtests=disabled
    ]

    mkdir "build" do
      system "meson", *args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    gst = Formula["gstreamer"].opt_bin/"gst-inspect-1.0"
    output = shell_output("#{gst} --gst-plugin-path #{lib} --plugin rtspclientsink")
    assert_match(/\s#{version}\s/, output)
  end
end
