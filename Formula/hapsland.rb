class Hapsland < Formula
  desc "Runtime-neutral code review integration for coding agents"
  homepage "https://github.com/dearlordylord/hapsland-releases"
  version "0.1.5"
  depends_on arch: :arm64

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.5/hapsland-0.1.5-darwin-arm64.tar.gz"
      sha256 "c32b10c7720bdb3e0a44735885f775151c27e97351c09144f0777e42a6ec6b3f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.5/hapsland-0.1.5-linux-arm64.tar.gz"
      sha256 "8244e18246e3eebcd94fd97476057a95c9fdbc5e2b0b04752c8e877460268ec5"
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
        hapsland setup

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
