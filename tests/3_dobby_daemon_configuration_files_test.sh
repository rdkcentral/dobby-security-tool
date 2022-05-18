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

test_3() {
	printtxt "\n${bldbluclr}3. Dobby Daemon Configuration File Test ${txtrst}"
}

test_3_1() {
  	local testid="3.1"
  	local desc="Ensure that the dobby.service file ownership is set to root:root"
  	local check="$testid - $desc"
  	local file

  	file="/lib/systemd/system/dobby.service"
  
  	if [ -f $file ]; then
  		if [ "$(stat -c %u%g "$file")" -eq 00 ]; then
      			pass "$check"
      			return
    		fi
    		fail "$check Wrong ownership for $file"
    		return
  	fi
  
  	warn "$check [ $file file is not found]"
}

test_3_2() {
  	local testid="3.2"
  	local desc="Ensure that dobby.service file permissions are appropriately set"
  	local check="$testid - $desc"
  	local file

  	file="/lib/systemd/system/dobby.service"
  
  	if [ -f $file ]; then
  		if [ "$(stat -c %a "$file")" -le 644 ]; then
      			pass "$check"
      			return
    		fi
    		fail "$check"
    		return
  	fi
  
  	warn "$check [ $file file is not found]"
}

test_3_3() {
  	local testid="3.3"
  	local desc="Ensure that dobbyPty.sock file ownership is set to root:root"
  	local check="$testid - $desc"
 
    	if [ "$(stat -c %u%g "/tmp/dobbyPty.sock")" -eq 00 ]; then
    		pass "$check"
      		return
    	fi
    	fail "$check"
}

test_3_4() {
  	local testid="3.4"
  	local desc="Ensure that dobbyPty.sock file permissions are set to 644 or more restrictive"
  	local check="$testid - $desc"

    	if [ "$(stat -c %a "/tmp/dobbyPty.sock")" -le 644 ]; then
    		pass "$check"
      		return
    	fi
    	fail "$check"
}

test_3_17() {
 	local testid="3.17"
  	local desc="Ensure that the dobby.json file ownership is set to root:root"
  	local check="$testid - $desc"
  	local file

  	file="/etc/dobby.json"
  
  	if [ -f $file ]; then
  		if [ "$(stat -c %u%g "$file")" -eq 00 ]; then
      			pass "$check"
      			return
    		fi
    		fail "$check"
    		return
  	fi
  
  	warn "$check [ $file file is not found]"
}

test_3_18() {
  	local testid="3.18"
  	local desc="Ensure that dobby.json file permissions are set to 644 or more restrictive"
  	local check="$testid - $desc"
  	local file

  	file="/etc/dobby.json"
  
  	if [ -f $file ]; then
  		if [ "$(stat -c %a "$file")" -le 644 ]; then
      			pass "$check"
      			return
    		fi
    		fail "$check"
   	 	return
  	fi
  
  	warn "$check [ $file file is not found]"
}
