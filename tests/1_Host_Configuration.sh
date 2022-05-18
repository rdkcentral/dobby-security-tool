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

test_1() {
	printtxt "\n${bldbluclr}1. Host Configuration ${txtrst}"
}

test_1_2_2() {
	local testid="1.2.2"
  	local desc="Ensure that the version of Dobby is up to date"
  	local check="$testid - $desc"
 	local output=$DobbyVersion
  	local crun=$crunVersion
 
  	crun=$(echo $crun | sed 's/commit[^-]*$//')
  	printf "%b\n" "${bldmgnclr}[MANUAL] $check ${bldwhtclr} \n Dobby $output \n $crun  $1${txtrst} "
  	totalmanual=$((totalmanual+1))
}
