args@
{ stdenv, fetchFromGitHub ? null, pkg-config, autoreconfHook, db48, boost, zeromq
, zlib, miniupnpc, qtbase ? null, qttools ? null, util-linux ? null, hexdump ? null, protobuf, python3, qrencode, libevent
, lcov ? null
, lib, writeText
, withSource ? null
, withBench ? false
, withWallet ? true
, withCoverage ? false
, withFuzz ? false
, doCheck ? (doFunctionalTests || withCoverage)
, withTests ? doCheck
, doFunctionalTests ? true
, qaAssetsDir ? null
, unitTestDataDir ? if qaAssetsDir != null then "${qaAssetsDir}/unit_test_data" else null
, fuzzSeedCorpusDir ? if qaAssetsDir != null then "${qaAssetsDir}/fuzz_seed_corpus" else null
}:

let withAssets = doCheck && (withCoverage || doFunctionalTests); in
with lib;
stdenv.mkDerivation rec {
  pname = "elements";
  version = if withSource == null then "22.2.1" else "custom";

  src = if withSource != null then withSource else
        fetchFromGitHub {
          owner = "ElementsProject";
          repo = "elements";
          rev = "elements-${version}";
          sha256 = "sha256-qHtSgfZGZ4Beu5fsJAOZm8ejj7wfHBbOS6WAjOrCuw4=";
        };

  postPatch = optionals (doCheck)
  ''
    patchShebangs contrib/filter-lcov.py
    patchShebangs test/functional
    patchShebangs test/fuzz
  '';

  nativeBuildInputs = [ pkg-config autoreconfHook ]
                   ++ optionals stdenv.isLinux [ util-linux ]
                   ++ optionals stdenv.isDarwin [ hexdump ]
                   ++ optionals withCoverage [ lcov stdenv.cc.cc.libllvm ];
  buildInputs = [ db48 boost zlib zeromq
                  miniupnpc protobuf libevent];

  nativeCheckInputs = [ python3 ];

  configureFlags = [ "--with-boost-libdir=${boost.out}/lib"
                     "--with-boost=${boost.dev}"
                   ] ++ optionals (withCoverage) [
                     "--enable-lcov --enable-lcov-branch-coverage"
                   ] ++ optionals (withFuzz) [
                     "--enable-fuzz --with-sanitizers=address,fuzzer,undefined"
                   ] ++ optionals (!withBench) [
                     "--disable-bench"
                   ] ++ optionals (!withWallet) [
                     "--disable-wallet"
                   ] ++ optionals (!withTests && !withFuzz) [
                     "--disable-tests"
                     "--disable-gui-tests"
                   ];
  inherit doCheck;
  ${ if doCheck then "DIR_UNIT_TEST_DATA" else null} = unitTestDataDir;
  ${ if doCheck then "DIR_FUZZ_SEED_CORPUS" else null} = fuzzSeedCorpusDir;
  checkFlags = [ "LC_ALL=C.UTF-8" ];
  testRunnerFlags = [ ]; # ++ optionals enableParallelBuilding [ "-j=$NIX_BUILD_CORES" ];
  checkTarget = if withCoverage then (if withFuzz then "cov_fuzz" else "cov") else "check";
  preCheck = optionals (withCoverage) ''
    # clang seems to have some sort of bug in '--coverage' which generates .gcno files that incorrectly think boost header files in elements/src/include/boost. 
    # This causes a bunch of warnings during the build and will caue genhtml to fail.
    # This workaround is to ignore errors in genhtml.
    # Though it is probably better to update the filter used in the build process to exclude these incorrect boost files and other non-src files.
    checkFlagsArray+=(GENHTML="${lcov}/bin/genhtml --ignore-errors source")
  '';
  postCheck = if (!withCoverage && doFunctionalTests)
  then ''
    (cd test/functional && python3 test_runner.py $testRunnerFlags)
  ''
  else "";

  makeFlags = [ "VERBOSE=true" ];

  postInstall = optionals (withFuzz)
  [ ''
    cp src/test/fuzz/fuzz $out/bin/fuzz
  ''] ++ optional (withCoverage)
  [''
    mkdir -p $out/share
    cp -r *.coverage $out/share/
  ''];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Open Source implementation of advanced blockchain features extending the Bitcoin protocol";
    longDescription= ''
      The Elements blockchain platform is a collection of feature experiments and extensions to the
      Bitcoin protocol. This platform enables anyone to build their own businesses or networks
      pegged to Bitcoin as a sidechain or run as a standalone blockchain with arbitrary asset
      tokens.
    '';
    homepage = "https://www.github.com/ElementsProject/elements";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
