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

test_2() {
    printtxt "\n${bldbluclr}2. Dobby Daemon Configuration Test ${txtrst}"
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

test_2_3() {
    local testid="2.3"
    local desc="Ensure the logging level is set to 'info'"
    local check="$testid - $desc"
    local output
    local output_1
    local sink

    output=$(crun --root /run/rdk/crun list | grep $containername | awk '{print $4}')
    sink=$(cat $output/config.json | grep sink | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

    # tolower sink, as it is case insensitive inside Dobby
    sink=$(echo "$sink" | awk '{print tolower($0)}')

    if [ "$sink" != "file" -a "$sink" != "devnull" ]; then
        output_1=$(cat $output/config.json | grep priority | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
        if [ "$output_1" == "LOG_INFO"  ]; then
            pass "$check"
        else
            fail "$check"
            verbosetxt "Priority different than LOG_INFO = $output_1"
        fi
    else
        pass "$check"
        verbosetxt "Logging to file or devnull doesn't require setting level"
    fi
}

test_2_9() {
    local testid="2.9"
    local desc="Enable user namespace support"
    local check="$testid - $desc"
    local output

    output=$(cat /proc/$Container_PID/status | grep '^Uid:' | awk '{print $3}')
    if [ "$output" == "0"  ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_2_17() {
    local testid="2.17"
    local desc="Ensure that a daemon-wide custom seccomp profile is applied if appropriate"
    local check="$testid - $desc"
    local DobbyDaemon_PID
    local output

    DobbyDaemon_PID=$(pidof DobbyDaemon)
    output=$(grep Seccomp /proc/$DobbyDaemon_PID/status | awk '{print $2}')

    if [ "$output" == "0" ]; then
        warn "$check"
        verbosetxt "Seccomp is not enabled"
        return
    elif [ "$output" == "1" -o "$output" == "2" ]; then
        pass "$check"
    else
        warn "$check"
        verbosetxt "Seccomp is not enabled"
    fi
}

