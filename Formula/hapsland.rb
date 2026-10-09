class Hapsland < Formula
  desc "Runtime-neutral code review integration for coding agents"
  homepage "https://github.com/dearlordylord/hapsland-releases"
  version "0.1.2"
  depends_on arch: :arm64

  on_macos do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.2/hapsland-0.1.2-darwin-arm64.tar.gz"
      sha256 "cb9bcff676563192ad389d6a6cd77fe85e2e2081622b7513a15d8330cd47dbfb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dearlordylord/hapsland-releases/releases/download/v0.1.2/hapsland-0.1.2-linux-arm64.tar.gz"
      sha256 "3743d85a5ea9a3bc58b02c15386081b8b6e6e7c13d6d9b4dda93793bbd51d538"
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
