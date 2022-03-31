#!/bin/bash

test_2_1() {
  local testid="2.1"
  local desc="Run the Dobby daemon as a non-root user, if possible"
  local check="$testid - $desc"
  local output
  
  output=$(ps -fe | grep "DobbyDaemon"| awk '{print $1}')
  output=$(echo $output |awk '{print $1}')
  if [ "$output" == "root" ]; then
      warn "$check"
	  return
  fi
  pass "$check"
}


test_2_9() {
	local testid="2.9"
	local desc="Enable user namespace support"
	local check="$testid - $desc"
	local DobbyInit_PID
	local output
  
	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')

	output=$(cat /proc/$DobbyInit_PID/status | grep '^Uid:' | awk '{print $3}')
   
    if [ "$output" == "0"  ]; then
      fail "$check"
      return
    fi
    pass "$check"
}
