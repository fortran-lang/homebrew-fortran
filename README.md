# Brew formulas for Fortran

This repository provides package build instructions for tools and libraries around Fortran compatible with the [Homebrew toolchain](https://brew.sh).

The [`lfortran`](https://lfortran.org) compiler is installed from this tap:

```sh
brew install fortran-lang/fortran/lfortran
```

[`fpm`](https://fpm.fortran-lang.org) and [`fortls`](https://fortls.fortran-lang.org) are available from Homebrew directly:

```sh
brew install fpm
brew install fortls
```

## Updating a formula

1) The daily `version_detector` workflow checks for new releases and opens a version-bump PR if it finds one.
2) The `test` workflow builds the formula from source on all supported platforms (2x macOS ARM64, 2x Linux) and uploads the bottles as CI artifacts. Wait until it is green.
3) Add the `pr-pull` label to the PR. Only do this after CI is green, otherwise bottles will be missing.
4) This triggers the `publish` workflow, which runs `brew pr-pull`: it downloads the bottles, commits the `bottle` block to the formula, pushes to `main`, and cleans up the PR branch. Do not merge the PR manually.

## License

The package build files are available under a [BSD-2-Clause license](LICENSE).
