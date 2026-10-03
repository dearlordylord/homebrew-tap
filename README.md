# Bend tools for Homebrew

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

The formula downloads immutable, versioned release assets from [bend-idea](https://github.com/dearlordylord/bend-idea). Publish and verify the four platform archives there before changing the formula. Update all four versioned URLs and SHA-256 values from the verified `BEND-FORMAT-SHA256SUMS.txt`. Keep the complete runtime, licenses and notices together under `libexec`; link only the launcher into `bin`.

CI installs and tests the actual formula on macOS Intel/Apple Silicon and Linux x64/ARM64. Runtime security updates arrive in new formatter distributions; refresh the formula when those releases ship.
