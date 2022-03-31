#!/bin/bash

test_1_2_2() {
  local testid="1.2.2"
  local desc="Ensure that the version of Dobby is up to date"
  local check="$testid - $desc"
  local output=$DobbyVersion
  local crun=$crunVersion
  crun=$(echo $crun | sed 's/commit[^-]*$//')
  printf "%b\n" "${bldcynclr}[MANUAL] $check ${bldwhtclr} \nDobby $output \n$crun  $1${txtrst} "
}
