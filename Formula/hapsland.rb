class Hapsland < Formula
  desc "Runtime-neutral code review integration for coding agents"
  homepage "https://github.com/dearlordylord/hapsland-releases"
  version "0.1.0"
  depends_on arch: :arm64

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.0/hapsland-0.1.0-darwin-arm64.tar.gz"
      sha256 "62140a733cf5347768502f28f8713b620ebe2afab2c013fceaf70179bd76745d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.0/hapsland-0.1.0-linux-arm64.tar.gz"
      sha256 "f7ac97c26551f53eabc266ec8d83f80109b5a73f90c68ca58c2d4497f5bd3b2c"
    end
  end

  def install
    libexec.install Dir["*"]
    %w[hapsland hapsland-hook hapsland-resident hapsland-parser hapsland-doctor].each do |command|
      bin.install_symlink libexec/"bin/launch.sh" => command
    end
  end

  def caveats
    <<~EOS
      Package installation does not activate coding-agent hooks. Run:
        #{opt_bin}/hapsland setup --target=#{opt_bin}/hapsland

      To update an existing installation, keep old packages until activation:
        HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade dearlordylord/tap/hapsland
        #{opt_bin}/hapsland update --target=#{opt_bin}/hapsland

      Do not remove old packages while hooks or running sessions still use them.
    EOS
  end

  test do
    assert_match(/usage/i, shell_output("#{bin}/hapsland --help"))
    assert_match "1.3.14", shell_output("#{bin}/hapsland-hook --runtime-identity")
    assert_match(/usage/i, shell_output("#{bin}/hapsland-resident --help"))
    assert_match(/usage/i, shell_output("#{bin}/hapsland-parser --help"))
    assert_match(/usage/i, shell_output("#{bin}/hapsland-doctor --help"))
  end
end
