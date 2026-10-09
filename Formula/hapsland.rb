class Hapsland < Formula
  desc "Runtime-neutral code review integration for coding agents"
  homepage "https://github.com/dearlordylord/hapsland-releases"
  version "0.1.1"
  depends_on arch: :arm64

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.1/hapsland-0.1.1-darwin-arm64.tar.gz"
      sha256 "6cd53330fe2ec9711d21b702423a8924a3a356f28459fccd48d0d710f4176f99"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.1/hapsland-0.1.1-linux-arm64.tar.gz"
      sha256 "c1e5712a335394bbbc7a496f3b457b422cda32b16b22c98b92f91272344015a3"
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
