#!/bin/bash

# If not stated otherwise in this file or this component's Licenses.txt file the
# following copyright and licenses apply:
#
# Copyright © 2022 Tata Elxsi Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

test_2() {
printtxt "\n${bldbluclr}Dobby Daemon Configuration Test ${txtrst}"
}

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
