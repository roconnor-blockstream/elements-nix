# elements-nix
Nix expression for building elements in various configurations.

This document assumes you are familiar with [elements](https://github.com/ElementsProject/elements) and its testing infrastructure.

## Basic Usage

Build elements without running tests.

    [~/elements-nix]$ nix-build

### Running Tests

Build elements and run the unit tests.

    [~/elements-nix]$ nix-build --arg doCheck true

Build elements and run both the unit tests and the functional tests.

    [~/elements-nix]$ nix-build --arg doFunctionalTests true

### Coverage

Build elements with coverage and run tests (both unit and functional) to produce the coverage analysis

    [~/elements-nix]$ nix-build --arg withCoverage true

Build the fuzzer binary for elements.  This binary can be used to create `qa-assets/fuzz_seed_corpus` similar to what is found in [qa-assets](https://github.com/ElementsProject/qa-assets).

    [~/elements-nix]$ nix-build --arg withFuzz true

Build the fuzzer binary for elements and use the qa-assets to produce coverage analys

    [~/elements-nix]$ nix-build --arg withFuzz true --arg withCoverage

## Advanced Usage

Suppose `elements-nix` is checked out into `~/elements-nix` and `elements` is checked out into `~/elements`.

If you have made some local changes to elements or have a specific branch checked out that you want to build.

⚠️ Untracked files are ignored. Be sure to stage any new files you want to include in the build.

💡 The `gitDir` value is passed to `builtins.fetchGit` and can be an attribute set.


    [~/elements]$ nix-build ~/elements-nix --arg gitDir ./.

If you want to develop elements in its directory.

    [~/elements]$ nix-shell ~/elements-nix
    [nix-shell:~/elements>]$ autoreconfPhase
    [nix-shell:~/elements>]$ configurePhase
    [nix-shell:~/elements>]$ buildPhase
    [nix-shell:~/elements>]$ checkPhase

If you want to build your local elements version and test it with your local qa-assets version.

    [~/elements]$ nix-build ~/elements-nix --arg gitDir ./. --arg qaAssetsDir ~/qa-assets --arg doFunctionalTests true

If you want to build your local elements version and test it with your [local unit-tests data](https://github.com/uncomputable/asset-gen).

    [~/elements]$ nix-build ~/elements-nix --arg gitDir ./. --arg unitTestDataDir ~/asset-gen --arg doFunctionalTests true
