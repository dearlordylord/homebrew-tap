class Hapsland < Formula
  desc "Runtime-neutral code review integration for coding agents"
  homepage "https://github.com/dearlordylord/hapsland-releases"
  version "0.1.3"
  depends_on arch: :arm64

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.3/hapsland-0.1.3-darwin-arm64.tar.gz"
      sha256 "ffb36db0b17c9b963a97a72515940098655d09b53acffa91456447e9bb389f2e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.3/hapsland-0.1.3-linux-arm64.tar.gz"
      sha256 "da5d0072a908ffb4e86ecab92702025a433b8f7506ff74e069564c722c039089"
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
