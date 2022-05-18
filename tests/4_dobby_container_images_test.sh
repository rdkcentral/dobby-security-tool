#!/bin/bash

# If not stated otherwise in this file or this component's LICENSE file the
# following copyright and licenses apply:
#
# Copyright 2022 RDK Management
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

test_4() {
	printtxt "\n${bldbluclr}4. Dobby Container Images Test ${txtrst}"
}

test_4_1() {
	local testid="4.1"
	local desc="Ensure that a user for the container has been created"
	local check="$testid - $desc"
	local child_pid
	local DobbyInit_PID
	local output
	
	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	
	child_pid=$(ps h --ppid $DobbyInit_PID -o pid | sed 's/ //g')

	output=$(cat /proc/$child_pid/status | grep '^Uid:' | awk '{print $3}')
   
   	if [ "$output" == "0"  ]; then
      		fail "$check"
      		return
    	fi
    	pass "$check"
}

test_4_8() {
	local testid="4.8"
        local desc="Ensure setuid and setgid permissions are removed"
        local check="$testid - $desc"
	local DobbyInit_PID
	local output

	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	output=$(find /proc/$DobbyInit_PID/root/ -perm /6000 2>/dev/null)
	if [ "$output" == ""  ]; then
		pass "$check"
      		return
   	fi
		
        fail "$check"
	if [ -n "$verbose" ]; then
		var=$(ls -lh $output | cut -d "/" -f5-)
		printtxt " $var"
	fi

}
