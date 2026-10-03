class BendFormat < Formula
  desc "Formatter and style checker for Bend source files"
  homepage "https://github.com/dearlordylord/bend-idea#standalone-formatter-and-style-checker"
  license all_of: [
    "Apache-2.0",
    "GPL-2.0-only" => { with: "Classpath-exception-2.0" },
  ]

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.13/bend-format-0.1.13-macos-aarch64.tar.gz"
      sha256 "fce2b91d6068b54d52a5f0416e06906d2e04e32fa8c93d63bee48d889c013979"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.13/bend-format-0.1.13-macos-x64.tar.gz"
      sha256 "1bdc19a86c719eb57060b868c3f5bc267991fedc6a23d9c9053c8a78a80e3850"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.13/bend-format-0.1.13-linux-aarch64.tar.gz"
      sha256 "e7c091aedcd564e34809e54772d5ee907c0ab400e6b4ab64585e5e85b2be40dc"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.13/bend-format-0.1.13-linux-x64.tar.gz"
      sha256 "387371a917f2b2a300a7455a3ead6ae9ff1c2268644c48c7915511b51d7c69f1"
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

    # Tuple/list syntax and an indented result-arrow continuation must remain
    # supported by the installed release, including repeat formatting.
    coverage = <<~BEND
      def pair(+x: U32,+y: U32)
          -> U32 & U32:
        values = [x,y]
        (x,y)
    BEND
    expected = <<~BEND
      def pair(+x: U32, +y: U32)
          -> U32 & U32:
        values = [x, y]
        (x, y)
    BEND
    (testpath/"coverage.bend").write coverage
    assert_match "would-change:", shell_output("#{bin}/bend-format check coverage.bend", 1)
    assert_equal coverage, (testpath/"coverage.bend").read
    system bin/"bend-format", "fix", "coverage.bend"
    assert_equal expected, (testpath/"coverage.bend").read
    system bin/"bend-format", "fix", "coverage.bend"
    assert_equal expected, (testpath/"coverage.bend").read
    system bin/"bend-format", "check", "coverage.bend"
    assert_match "unavailable:", shell_output("#{bin}/bend-format check missing.bend", 2)
  end
end
