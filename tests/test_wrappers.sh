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
  assertTrue "Git should be present and working" "git --version"
}

testCheckdeps(){
  which git-cms-checkdeps
  cd $SHUNIT_TMPDIR
  assertTrue "Release should not be there"  "[ ! -d CMSSW_7_0_0_pre0 ]"
  assertTrue "SCRAM is missing" "scram project CMSSW_7_0_0_pre0" || return 1
  assertTrue "Should be able to create release" "[ -d CMSSW_7_0_0_pre0 ]"
  assertFalse "Should require CMSSW environment" "git-cms-checkdeps"
  cd CMSSW_7_0_0_pre0
  eval `scram run -sh`
  assertTrue   "Should checkout FWCore/Framework" "git-cms-addpkg FWCore/Framework"
  # Test $Id:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo 'nbcdjksnckjsa\$Id: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "Should CVS Ids should be ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Author:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\$Author: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "Should CVS Ids should be ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Log:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\$Log: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "Should CVS Ids should be ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Revision:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\$Revision: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "Should ignore CVS \$Revision\$" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Revision:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo 'cdjknsncjksanadjks\$Revision: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "Should ignore CVS \$Revision\$ (with extra stuff)" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Source:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo ' \$Source: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "CVS Source should have been ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Source:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\$Source: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "CVS Source (with space) should have be ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test $Header:$
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\$Header: Foo$' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "CVS Header should have be ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  # Test Two keywords
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\$Revision: Foo$ $Id:bar $' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps 1" "git-cms-checkdeps -a"
  assertEquals "Two CVS keywords should have been ignored" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`

  # Check for a real change.
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '\n//foo' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps" "git-cms-checkdeps"
  git cms-checkdeps
  assertEquals "Should have created FWCore/Framework only" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  assertTrue "Should run checkdeps" "git-cms-checkdeps -a"
  assertEquals "Should have created a bunch of stuff" "10" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  rm -rf src
  # Check for half backed keyword.
  assertTrue   "Should checkout FWCore/Framework" "git-cms-addpkg FWCore/Framework"
  assertTrue "File src/FWCore/Framework/interface/EDLooper.h should be there" "echo '// $Id:' >> src/FWCore/Framework/interface/EDLooper.h"
  assertTrue "Should run checkdeps" "git-cms-checkdeps"
  assertEquals "Should have created FWCore/Framework only" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  assertTrue "Should run checkdeps" "git-cms-checkdeps -a"
  assertEquals "Should have created a bunch of stuff" "10" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  eval `scram unsetenv -sh`
}

testAddpkg(){
  cd $SHUNIT_TMPDIR
  # Without CMSSW environment.
  assertEquals "\$CMSSW_VERSION should not be set." "" "$CMSSW_VERSION"
  assertFalse "Needs a tag if \$CMSSW_VERSION not there" "git-cms-addpkg FWCore/Version"
  assertFalse "Should not create a directory" "[ -d src/FWCore/Version ]"
  # With CMSSW environment.
  rm -rf CMSSW_7_0_0_pre0
  assertTrue "SCRAM is missing" "scram project CMSSW_7_0_0_pre0" || return 1
  assertTrue "Should be able to create release" "[ -d CMSSW_7_0_0_pre0 ]"
  assertFalse "Should require CMSSW environment" "git-cms-checkdeps"
  cd CMSSW_7_0_0_pre0
  eval `scram run -sh`
  assertTrue  "Should complete successfully" "git-cms-addpkg FWCore/Version CMSSW_7_0_0_pre0" 
  assertTrue  "Should have created FWCore/Version" "[ -d src/FWCore/Version ]"
  assertEquals "Should have created FWCore/Version only" "1" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  assertFalse  "Should not run with a different tag than then initial one" "git-cms-addpkg FWCore/Version CMSSW_6_2_0_pre8"
  assertTrue   "Should checkout a different package" "git-cms-addpkg DataFormats/TestObjects CMSSW_7_0_0_pre0"
  assertEquals "Should have created 2 packages" "2" `find src -maxdepth 2 -mindepth 2 ! -path "**/.git/*" -type d | wc -l`
  assertTrue  "Should have created DataFormats/TestObjects" "[ -d src/DataFormats/TestObjects ]"
  eval `scram unsetenv -sh`
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
