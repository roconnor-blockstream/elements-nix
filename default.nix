{ nixpkgs ? import <nixpkgs> {}
, doFunctionalTests ? false
, withBench ? false
, withCoverage ? false
, withFuzz ? false
, doCheck ? (doFunctionalTests || withCoverage)
, withTests ? doCheck
, withWallet ? true
, gitDir ? null
, qaAssetsDir ?
        nixpkgs.fetchFromGitHub {
          owner = "roconnor-blockstream";
          repo = "qa-assets";
          rev = "d1e7bcf1b6d062bdeb0da9680b5ae2ea29dfba6b"; # temporary workaround
          sha256 = "sha256-hLYDK5OX33kwflb1OOn1q/1cZnOclw+qbtP135pQDRE=";
        }
#        nixpkgs.fetchFromGitHub {
#          owner = "ElementsProject";
#          repo = "qa-assets";
#          rev = "0c315a2951619857b8d02fadb6b1eda3c746b837";
#          sha256 = "sha256-N8TqPPtHSOyHKuAS295Cf5bNsKNBYwoC/9/5QQgtUXk=";
#        }
, unitTestDataDir ? if qaAssetsDir != null then "${qaAssetsDir}/unit_test_data" else null
, fuzzSeedCorpusDir ? if qaAssetsDir != null then "${qaAssetsDir}/fuzz_seed_corpus" else null
}:
nixpkgs.callPackage ./elements.nix {
  inherit doCheck doFunctionalTests withBench withCoverage withFuzz withTests withWallet
          qaAssetsDir unitTestDataDir fuzzSeedCorpusDir;
  boost = nixpkgs.boost175;
  miniupnpc = nixpkgs.callPackage ./miniupnpc-2.2.7.nix { };
  lcov = nixpkgs.callPackage ./lcov-1.16.nix { };
  stdenv = nixpkgs.clangStdenv;
  ${if gitDir == null then null else "withSource"} = builtins.fetchGit gitDir;
}
