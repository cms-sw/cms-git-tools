#!/bin/sh
if [ "X$WORKSPACE" = X ]; then
  SHUNIT_TMPDIR="$WORKSPACE"
fi
export CUR_PATH=$PWD
export PATH=$PWD:$PATH

testPaths () {
  gitCmsAddpkg="`which git-cms-addpkg`"
  gitCmsMergeTopic="`which git-cms-merge-topic`"
  gitCmsCheckdeps="`which git-cms-checkdeps`"
  assertEquals "Not testing the correct git-cms-addpkg" `dirname "$gitCmsAddpkg"` "$CUR_PATH"
  assertEquals "Not testing the correct git-cms-merge-topic" `dirname "$gitCmsMergeTopic"` "$CUR_PATH"
  assertEquals "Not testing the correct git-cms-checkdeps" `dirname "$gitCmsCheckdeps"` "$CUR_PATH"
}

testCheckdeps(){
  cd $SHUNIT_TMPDIR
  assertTrue "Release should not be there"  "[ ! -d CMSSW_7_0_0_pre0 ]"
  assertTrue "SCRAM is missing" "scram project CMSSW_7_0_0_pre0" || return 1
  assertTrue "Should be able to create release" "[ -d CMSSW_7_0_0_pre0 ]"
  assertFalse "Should require CMSSW environment" "git-cms-checkdeps"
  cd CMSSW_7_0_0_pre0
  eval `scram run -sh`
  assertTrue   "Should checkout FWCore/Framework" "git-cms-addpkg FWCore/Framework"
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo ' ' >> src/FWCore/Framework/interface/EDLooper.h"
  ls src
  assertTrue "Should run checkdeps" "git-cms-checkdeps"
  ls src
  assertEquals "Should have created FWCore/Framework only" "1" `find src ! -path "**/.git/*" -type d -maxdepth 2 -mindepth 2 | wc -l`
  assertTrue "Should run checkdeps" "git-cms-checkdeps -a"
  ls src
  assertEquals "Should have created FWCore/Framework only" "10" `find src ! -path "**/.git/*" -type d -maxdepth 2 -mindepth 2 | wc -l`
  eval `scram unsetenv -sh`
}

testAddpkg(){
  cd $SHUNIT_TMPDIR
  assertEquals "\$CMSSW_VERSION should not be set." "" "$CMSSW_VERSION"
  assertFalse "Needs a tag if \$CMSSW_VERSION not there" "git-cms-addpkg FWCore/Version"
  assertFalse "Should not create a directory" "[ -d src/FWCore/Version ]"
  assertTrue  "Should complete successfully" "git-cms-addpkg FWCore/Version CMSSW_7_0_0_pre0" 
  assertTrue  "Should have created FWCore/Version" "[ -d src/FWCore/Version ]"
  assertEquals "Should have created FWCore/Version only" "1" `find src ! -path "**/.git/*" -type d -maxdepth 2 -mindepth 2 | wc -l`
  assertFalse  "Should not run with a different tag than then initial one" "git-cms-addpkg FWCore/Version CMSSW_6_2_0_pre8"
  assertTrue   "Should checkout a different package" "git-cms-addpkg DataFormats/TestObjects CMSSW_7_0_0_pre0"
  assertEquals "Should have created 2 packages" "2" `find src ! -path "**/.git/*" -type d -maxdepth 2 -mindepth 2 | wc -l`
  assertTrue  "Should have created DataFormats/TestObjects" "[ -d src/DataFormats/TestObjects ]"
}

oneTimeSetup() {
  mkdir "${outputDir}"
  stdoutF="${outputDir}/stdout"
  stderrF="${outputDir}/stderr"
}

#Download shunit2 suite if needed.
if [ ! -f tests/shunit2-2.1.6/src/shunit2 ]; then
  pushd tests
    curl -O http://shunit2.googlecode.com/files/shunit2-2.1.6.tgz
    tar xzf shunit2-2.1.6.tgz
  popd
fi

source tests/shunit2-2.1.6/src/shunit2
