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

# Color codes
bldredclr='\033[1;31m' # Bold Red
bldgrnclr='\033[1;32m' # Bold Green
bldbluclr='\033[1;34m' # Bold Blue
bldcynclr='\033[1;36m' # Bold yellow
bldylwclr='\033[1;33m' # Bold cyan
bldmgnclr='\033[1;35m' # Bold Magenta
bldwhtclr='\033[1;37m' # Bold white
light_ylw='\033[0;33m' # light yellow
txtrst='\033[0m'	   # No Color


# Print the text
printtxt () {
  printf "%b\n" "$1"
}

# Info print
info () {
 printf "%b\n" "${bldbluclr}[INFO]${txtrst} $1"
}


# Pass Print
pass () {
printf "%b\n" "${bldgrnclr}[PASS] $1${txtrst} "
totalpass=$((totalpass + 1))
}

# Fail Print
fail () {
 printf "%b\n" "${bldredclr}[FAIL] $1${txtrst} "
    totalfail=$((totalfail + 1))
}

# Warning Print
warn () {
    printf "%b\n" "${bldylwclr}[WARN] $1${txtrst} "
	totalwarn=$((totalwarn + 1))
}

header () {
  printf "%b\n" "${bldcynclr}$1${txtrst}\n"
}

# Header Version details
header_info() {
header "# ============================================================================================
# Dobby Security Tool                                                                  
#                                                                                            
# A script based tool for security vulnerability scanning of dobby container                        
# ============================================================================================"
}

# Check for required program(s)
req_programs() {
  for p in $1; do
    command -v "$p" >/dev/null 2>&1 || { printf "Required program not found: %s\n" "$p"; exit 1; }
  done
  if command -v ss >/dev/null 2>&1; then
    netbin=ss
    return
  fi
  if command -v netstat >/dev/null 2>&1; then
    netbin=netstat
    return
  fi
  echo "ss or netstat command not found."
  exit 1
}
