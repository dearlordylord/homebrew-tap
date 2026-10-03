class BendFormat < Formula
  desc "Formatter and style checker for Bend source files"
  homepage "https://github.com/dearlordylord/bend-idea#standalone-formatter-and-style-checker"
  license all_of: [
    "Apache-2.0",
    "GPL-2.0-only" => { with: "Classpath-exception-2.0" },
  ]

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.14/bend-format-0.1.14-macos-aarch64.tar.gz"
      sha256 "61380879545d73f2df8fd508923c63d8054f7df31208bdd4d278e23e14247e68"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.14/bend-format-0.1.14-macos-x64.tar.gz"
      sha256 "af96730ea24ad4af8ad9c2d6b8232a65e60ab3e023e908657b61ae003b8823ce"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.14/bend-format-0.1.14-linux-aarch64.tar.gz"
      sha256 "7d6d58c367fc0a58d88ddaba5f2586067677129f398eb49336668814f96c146e"
    end
    on_intel do
      url "https://github.com/dearlordylord/bend-idea/releases/download/v0.1.14/bend-format-0.1.14-linux-x64.tar.gz"
      sha256 "6d615a089717b968fa93b6cefab7d3b6b02f26dda1c92666965644f1420e2472"
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
  end
end
