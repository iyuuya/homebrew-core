class DjlServing < Formula
  desc "This module contains an universal model serving implementation"
  homepage "https://github.com/awslabs/djl/tree/master/serving"
  url "https://djl-ai.s3.amazonaws.com/publish/djl-serving/serving-0.11.0.tar"
  sha256 "a7bdd3397744e7cca57dc551cca9180ee88f5e630d31cef01a46cfb0dc73f666"
  license "Apache-2.0"
  revision 1

  bottle do
    sha256 cellar: :any_skip_relocation, all: "40f1f4bfefc3627fcfad85dc6fab60249e3264e83c409374c04e24d375f32053"
  end

  depends_on "openjdk"

  def install
    # Install files
    rm_rf Dir["bin/*.bat"]
    mv "bin/serving", "bin/djl-serving"
    libexec.install Dir["*"]
    env = { MODEL_SERVER_HOME: "${MODEL_SERVER_HOME:-#{var}}" }
    env.merge!(Language::Java.overridable_java_home_env)
    (bin/"djl-serving").write_env_script "#{libexec}/bin/djl-serving", env
  end

  service do
    run [opt_bin/"djl-serving", "run"]
    keep_alive true
  end

  test do
    port = free_port
    (testpath/"config.properties").write <<~EOS
      inference_address=http://127.0.0.1:#{port}
      management_address=http://127.0.0.1:#{port}
    EOS
    ENV["MODEL_SERVER_HOME"] = testpath
    cp_r Dir["#{libexec}/*"], testpath
    fork do
      exec bin/"djl-serving -f config.properties"
    end
    sleep 30
    cmd = "http://127.0.0.1:#{port}/ping"
    assert_match "{\n  \"status\": \"Healthy\"\n}\n", shell_output("curl #{cmd}")
  end
end
