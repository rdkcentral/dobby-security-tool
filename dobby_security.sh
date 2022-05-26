#! /bin/bash

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

#  Version details
version=0.1
DobbyVersion=$(DobbyDaemon --version)
crunVersion=$(crun --version)


usage () {
  cat <<EOF

Checks for dozens of common best-practices around deploying Dobby containers in production.
Based on the CIS Docker Benchmark 1.3.1.
Usage: ./dobby_security.sh -c Netflix [OPTIONS] 
Options:
  -c    mandatory  Container name (Ensure the container is running)
  -h    optional   Print this help message
  -v	optional   prints the additional prints
  -t    optional   Comma delimited list of specific test(s) id
  -e    optional   Comma delimited list of specific test(s) id to exclude

EOF
}


# Get the flags
# If you add an option here, please
# remember to update usage() above.

while getopts bhl:c:t:e:v args
do
  case $args in
  c) containername="$OPTARG" ;;
  t) tests="$OPTARG" ;;
  e) testexclude="$OPTARG" ;;
  b) nocolor="nocolor";;
  v) verbose="verbose";;
  h) usage; exit 0 ;;
  esac
done


# Load outside scripts
. ./functions/output.sh
. ./functions/functions.sh

# Check for required program(s)
req_programs 'awk grep stat sed cut DobbyDaemon'

# Default Values
totalpass=0
totalfail=0
totalcount=0
totalwarn=0
totalmanual=0

# Header format
header_info

# Argument Validation
if [ "$containername" == "" -o "$1" == "" ]; then
	printtxt "${bldmgnclr} Error: 'Please enter valid container name' Ex:./dobby_security.sh -c Netflix [OPTIONS] ${txtrst}\n"
	exit 1
elif [ -n "$containername" ]; then
	containername=$containername
	input_valid
else
	echo " TEST"
fi


# Warn if not root
if [ "$(id -u)" != "0" ]; then
   printtxt "${bldmgnclr} Warning: 'Some tests might require root to run' ${txtrst}\n"
  sleep 3
fi

printtxt "Initializing the test $(date)\n"

# Load all the tests from tests/ and run them
main() {

for test in tests/*.sh; do
    . ./"$test"
  done


  if [ -z "$tests" ] && [ ! "$testexclude" ]; then
    # No options just run
    all
  elif [ -z "$tests" ]; then
    # No tests defined but excludes defined set to calls in all() function
    tests=$(sed -ne "/all() {/,/}/{/{/d; /}/d; p}" functions/functions.sh)
  fi
   
  for t in $(echo "$tests" | sed "s/,/ /g"); do
    if ! command -v "$t" 2>/dev/null 1>&2; then
      echo "Test \"$t\" doesn't seem to exist."
      continue
    fi
    if [ -z "$testexclude" ]; then
      # No excludes just run the checks specified
      "$t"
    else
      # Exludes specified and test exists
      testexcluded="$(echo ",$testexclude" | sed -e 's/^/\^/g' -e 's/,/\$|/g' -e 's/$/\$/g')"

      if echo "$t" | grep -E "$testexcluded" 2>/dev/null 1>&2; then
        # Excluded
        continue
      elif echo "$t" | grep -vE 'test_[0-9]| test_[a-z]' 2>/dev/null 1>&2; then
        # Function not a check, fill loop_tests with all check from function
        loop_tests="$(sed -ne "/$t() {/,/}/{/{/d; /}/d; p}" functions/functions.sh)"
      else
        # Just one test
        loop_tests="$t"
      fi

      for lc in $loop_tests; do
        if echo "$lc" | grep -vE "$testexcluded" 2>/dev/null 1>&2; then
          # Not excluded
          "$lc"
        fi
      done
    fi
  done
  
totalcount=$(($totalpass+$totalfail+$totalwarn+$totalmanual))
printtxt "\n\n${bldbluclr}Test Results Summary${txtrst}"
printtxt "${txtrst}Total Pass 		    : $totalpass"
printtxt "${txtrst}Total Fail 		    : $totalfail"
printtxt "${txtrst}Total Warnings 	            : $totalwarn"
printtxt "${txtrst}Manual validation required  : $totalmanual"
printtxt "${txtrst}Total tests		    : $totalcount\n"

}

main "$@"
