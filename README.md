# Homebrew packages

**Purpose:** Install maintained ready-made tools from this tap.
**Status:** Maintained installation guidance.
**Authority:** Maintained guidance; each formula selects immutable release assets.
**Expected use:** Choose a tool and install or update it with Homebrew.
**Lifecycle:** Update with formula and installation-channel changes.

## Hapsland

On macOS arm64 or Linux arm64:

```sh
brew install dearlordylord/tap/hapsland
"$(brew --prefix hapsland)/bin/hapsland" setup --target="$(brew --prefix hapsland)/bin/hapsland"
```

Hapsland includes Bun and native assets. Package installation does not activate coding-agent hooks; setup previews changes and asks before applying them.

For an update, retain old packages until activation and use the new package explicitly:

```sh
HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade dearlordylord/tap/hapsland
"$(brew --prefix hapsland)/bin/hapsland" update --target="$(brew --prefix hapsland)/bin/hapsland"
```

Do not remove an old keg while hooks or running sessions still use it. [Public release archives and checksums](https://github.com/dearlordylord/hapsland-releases/releases) are available for installation without Homebrew.

## Bend formatter

Install the Bend formatter on macOS or Linux:

```sh
brew install dearlordylord/tap/bend-format
```

Then run from your project directory:

```sh
bend-format check src/main.bend
bend-format fix src/main.bend
```

Homebrew selects the archive for your machine and installs the command in its normal executable directory. The distribution includes everything needed to run the formatter. It uses local EditorConfig settings and does not invoke the Bend compiler.

Update or uninstall:

```sh
brew update
brew upgrade bend-format
brew uninstall bend-format
```

Need Homebrew first? Follow [brew.sh](https://brew.sh/). Windows users can download the ready-to-run archive from the [Bend2 releases](https://github.com/dearlordylord/bend-idea/releases/latest).

## Maintenance

Follow the [combined release procedure](https://github.com/dearlordylord/bend-idea/blob/master/docs/releasing.md) for formatter archives, version metadata and the IntelliJ custom repository.

The formula downloads immutable, versioned release assets from [bend-idea](https://github.com/dearlordylord/bend-idea). Publish and verify the four platform archives there before changing the formula. Update all four versioned URLs and SHA-256 values from the verified `BEND-FORMAT-SHA256SUMS.txt`. Keep the complete runtime, licenses and notices together under `libexec`; link only the launcher into `bin`.

CI installs and tests the actual formula on macOS Intel/Apple Silicon and Linux x64/ARM64. Runtime security updates arrive in new formatter distributions; refresh the formula when those releases ship.

For Hapsland, copy the formula generated from the verified platform distribution. Preserve the whole package under `libexec`, expose its five command aliases, and verify the actual installed package before pushing formula changes. Runtime layout and npm delivery remain separate from Homebrew packaging.
