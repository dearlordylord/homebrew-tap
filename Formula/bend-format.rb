class BendFormat < Formula
  desc "Formatter and style checker for Bend source files"
  homepage "https://github.com/dearlordylord/bend-idea#standalone-formatter-and-style-checker"
  license all_of: [
    "Apache-2.0",
    "GPL-2.0-only" => { with: "Classpath-exception-2.0" },
  ]

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.19/bend-format-0.1.19-macos-aarch64.tar.gz"
      sha256 "a50bc143004f23d4822abed3045baf1e004786cfca9bb65e92a71408bff56f4a"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.19/bend-format-0.1.19-macos-x64.tar.gz"
      sha256 "151319a591659fd1084686b3876d05e025c2ba5571a0f8496d7004173ae433ea"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.19/bend-format-0.1.19-linux-aarch64.tar.gz"
      sha256 "86871fba81600cca5059eac30295a9b5ba15e35f952510dcfef002dfc7e7cba9"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.19/bend-format-0.1.19-linux-x64.tar.gz"
      sha256 "ae3b1f66e6e12ede192dd027b17606c10e8b8051793e200f216f2bcb2dcc8f13"
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
