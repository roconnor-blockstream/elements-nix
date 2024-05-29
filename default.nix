{ nixpkgs ? import <nixpkgs> {}
, doFunctionalTests ? false
, withBench ? false
, withCoverage ? false
, withFuzz ? false
, doCheck ? (doFunctionalTests || withCoverage)
, withTests ? doCheck
, withWallet ? true
, srcDir ? null
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
  stdenv = nixpkgs.clangStdenv;
  ${if srcDir == null then null else "withSource"} =
    nixpkgs.lib.sourceFilesBySuffices srcDir [ ".ac" ".am" ".m4" ".in" ".include" ".mk" ".h" ".hpp" ".c" ".cc" ".cpp" ".inc" ".py" ".json" ".raw" ".sh" ".1" ".hex" ".csv" ".html" "Makefile"
      "san" # for lsan, tsan, and ubsan in test/sanitizer_suppresssions
    ];
}
