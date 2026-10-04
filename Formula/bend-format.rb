class BendFormat < Formula
  desc "Formatter and style checker for Bend source files"
  homepage "https://github.com/dearlordylord/bend-idea#standalone-formatter-and-style-checker"
  license all_of: [
    "Apache-2.0",
    "GPL-2.0-only" => { with: "Classpath-exception-2.0" },
  ]

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.17/bend-format-0.1.17-macos-aarch64.tar.gz"
      sha256 "d173462876dafbacd1a62d7c9ab510960fc930aec26c038b1fa5c24ccfd098f9"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.17/bend-format-0.1.17-macos-x64.tar.gz"
      sha256 "cb412d21a2942c5b156700dd8d1d4320529f18f451e7ce9dfdee9e7f832bac4b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.17/bend-format-0.1.17-linux-aarch64.tar.gz"
      sha256 "36b428d115d8243934cd572b16c124ee34f28fae8b6a5f811be8ab2f518be601"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.17/bend-format-0.1.17-linux-x64.tar.gz"
      sha256 "283664f8f845010a28bb994deb4a0124362008995109d78b0a08dd5ec14198a1"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/bend-format"
  end

  test do
    assert_equal "bend-format #{version}\n", shell_output("#{bin}/bend-format --version")
    help = shell_output("#{bin}/bend-format --help")
    assert_match "bend-format check FILE ...", help
    assert_match "Exit codes:", help
    assert_match "bend-format check FILE ...", shell_output("#{bin}/bend-format check --help")
    assert_match "Unknown option: --unknown", shell_output("#{bin}/bend-format check --unknown 2>&1", 2)
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
    (testpath/"-dash file.bend").write source
    system bin/"bend-format", "fix", "--", "-dash file.bend"
    assert_equal "def main(x: U32, y: U32) -> U32:\n  x\n", (testpath/"-dash file.bend").read
    system bin/"bend-format", "check", "--", "-dash file.bend"
    assert_match "file not found", shell_output("#{bin}/bend-format check missing.bend", 2)

    # Long equality propositions must wrap in the actual installed release.
    (testpath/".editorconfig").unlink
    (testpath/".editorconfig").write <<~EOS
      root = true
      [*.bend]
      indent_style = space
      indent_size = 2
      bend_max_line_length = 25
    EOS
    equality = <<~BEND
      law preserved:
        {combine(alpha, beta, gamma) == (combine(alpha, beta, gamma)) : Nat}
    BEND
    equality_expected = <<~BEND
      law preserved:
        {
          combine(
            alpha,
            beta,
            gamma
          )
          == (combine(
            alpha,
            beta,
            gamma
          ))
          : Nat
        }
    BEND
    (testpath/"equality.bend").write equality
    assert_match "would-change:", shell_output("#{bin}/bend-format check equality.bend", 1)
    assert_equal equality, (testpath/"equality.bend").read
    system bin/"bend-format", "fix", "equality.bend"
    assert_equal equality_expected, (testpath/"equality.bend").read
    system bin/"bend-format", "fix", "equality.bend"
    assert_equal equality_expected, (testpath/"equality.bend").read
    system bin/"bend-format", "check", "equality.bend"
  end
end
