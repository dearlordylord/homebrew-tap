class BendFormat < Formula
  desc "Formatter and style checker for Bend source files"
  homepage "https://github.com/dearlordylord/bend-idea#standalone-formatter-and-style-checker"
  version "0.1.12"
  license all_of: ["Apache-2.0", { "GPL-2.0-only" => { with: "Classpath-exception-2.0" } }]

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v#{version}/bend-format-#{version}-macos-aarch64.tar.gz"
      sha256 "856b1611682a462efe7cd261bb6e3683f8a3a25d4db313c9291c1a409bdd4fdb"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v#{version}/bend-format-#{version}-macos-x64.tar.gz"
      sha256 "0f657680b6af352041eae72537336842860dbda4376e914fafea6315b705ff69"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v#{version}/bend-format-#{version}-linux-aarch64.tar.gz"
      sha256 "c697425001f5835b233e35c1a3208af71cdfe2c275246c2d8cd73094ab469e02"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v#{version}/bend-format-#{version}-linux-x64.tar.gz"
      sha256 "fd96b2750bfe514d963830349a6267a6893268e79484a02754797676520535a1"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/bend-format"
  end

  test do
    assert_match "bend-format-tool #{version}", shell_output("#{bin}/bend-format --version")
    (testpath/".editorconfig").write <<~EOS
      root = true
      [*.bend]
      indent_style = space
      indent_size = 2
      bend_max_line_length = off
    EOS
    source = "def main(x: U32,y: U32) -> U32:\n    x\n"
    (testpath/"main.bend").write source
    assert_match "would-change:", shell_output("#{bin}/bend-format check main.bend", 1)
    assert_equal source, (testpath/"main.bend").read
    system bin/"bend-format", "fix", "main.bend"
    assert_equal "def main(x: U32, y: U32) -> U32:\n  x\n", (testpath/"main.bend").read
    system bin/"bend-format", "check", "main.bend"
    assert_match "unavailable:", shell_output("#{bin}/bend-format check missing.bend", 2)
  end
end
