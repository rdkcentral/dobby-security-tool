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

test_5() {
    printtxt "\n${bldbluclr}5. Dobby Container Runtime Test ${txtrst}"
}

test_5_1() {
    local testid="5.1"
    local desc="Ensure that, if applicable, an AppArmor Profile is enabled"
    local check="$testid - $desc"
    local output_1
    local output_2
    local file

    file="/sys/module/apparmor/parameters/enabled"
    if [ -f $file ]; then
        output_1=$(cat /sys/module/apparmor/parameters/enabled)
        if [ "$output_1" == "Y" ]; then
            output_2=$(cat /proc/$Container_PID/attr/current | grep -E 'complain|enforce')
            if [ "$output_2" == "" ]; then
                warn "$check"
                return
            else
                pass "$check"
                return
            fi

        fi
        warn "$check"

    else
        warn "$check"
    fi
}

test_5_3() {
    local testid="5.3"
    local desc="Ensure that Linux kernel capabilities are restricted within containers"
    local check="$testid - $desc"
    local output
    local input
    local ouputarr
    local status

    status=$(cat /proc/$Container_PID/status | grep CapPrm | awk '{print $2}')

    if command -v capsh >/dev/null 2>&1; then
        output=$(capsh --decode=$status | sed 's/.*=//g')

        input=( cap_net_raw cap_dac_read_search cap_sys_module cap_sys_admin cap_sys_ptrace )
        IFS=','

        read -a ouputarr <<<"$output"
        output_length=${#ouputarr[@]}
        input_length=${#input[@]}

        #accessing each element of array
        for (( i=0; i<output_length; i++ ));
        do
            for (( j=0; j<input_length; j++ ));
            do
                if [ "${ouputarr[$i]}" == "${input[$j]}" ]; then
                    fail "$check"
                    verbosetxt "${ouputarr[$i]} capability is permitted for container"
                    return
                fi
            done
        done
        pass "$check"
    else
        hex_value=$((16#$status))
        #cap_dac_read_search 2 #cap_net_raw 13 #cap_sys_module 16 #cap_sys_ptrace 19 #cap_sys_admin  21
        mask=$(((0x1 << 2) | (0x1 << 13) | (0x1 << 16) | (0x1 << 19) | (0x1 << 21)))
        result=$((hex_value & mask))
        if [ "$result" != 0 ]; then
            fail "$check"
            verbosetxt "${bldcynclr}Restricted capability is permitted for container$1${txtrst} "
            return
        else
            pass "$check"
        fi

    fi
}

test_5_5() {
    local testid="5.5"
    local desc="Ensure sensitive host system directories are not mounted on containers"
    local check="$testid - $desc"
    local output_1
    local output_2
    local output_3
    local var
    local readwrite=0
    local fullymounted=0

    output=$(cat /proc/$Container_PID/mounts | grep -E 'ext|fat|sqaushfs')
    #(considering only *ext*, *fat*, *squash* filesystem types

    output_1=$(echo $output| grep  -E 'boot|dev|etc|lib|proc|sys|usr|bin|sbin|opt')
    input=( "/boot" "/dev" "/etc" "/lib" "/proc" "/sys" "/usr" "/bin" "/sbin" "/opt" )

    for i in "${input[@]}"
    do
        var=$(echo $output_1 | grep -E "(^| )$i( |$)")
        if [ "$var" != "" ]; then
            output_2=$(cat /proc/$Container_PID/mountinfo | grep -E "(^| )$i( |$)")
            Fm_arr+=("$output_2");((fullymounted=fullymounted+1))
            output_3=$(echo $output_2 | awk '{print $6}'| cut -d ',' -f 1)

            if [ "$output_3" == "rw" ]; then
                ((readwrite=readwrite+1))
                Rw_arr+=("$output_2")
            fi

        fi

    done

    if [ "$readwrite" == "0" -a "$fullymounted" == "0" ]; then
        pass "$check"
        return
    elif [ "$fullymounted" -gt "0" -a "$readwrite" == "0" ]; then
        warn "$check"
        verbosetxt "${bldcynclr} The following directories are mounted fully in ro mode$1${txtrst} "
        if [ -n "$verbose" ]; then
            for index in "${Fm_arr[@]}"; do verbosetxt "${bldwhtclr} $index $1${txtrst}"; done
        fi
        return

    else
        fail "$check"
        verbosetxt "${bldcynclr} The following directories are mounted fully in rw mode$1${txtrst} "
        if [ -n "$verbose" ]; then
            for index in "${Rw_arr[@]}"; do verbosetxt "${bldwhtclr} $index $1${txtrst}"; done
        fi

    fi
}

test_5_5_1() {
    local testid="5.5.1"
    local desc="Ensure nosuid,nodev,noexec options are present in mount"
    local check="$testid - $desc"
    local output
    local counter_1=0
    local counter_2=0
    local flags
    local ouputarr

    output=$(cat /proc/$Container_PID/mountinfo)
    while read line;
    do
        flags=$(echo $line | grep nosuid | grep nodev | grep noexec)

        if [ "$flags" == "" ]; then
            counter_2=$((counter_2+1))
            line=$(echo $line | grep -o '/[^"]*')
            ouputarr+=("$line")
        else
            counter_1=$((counter_1+1))
        fi

    done <<< "$output"

    manual "$check"
    if [ "$counter_2" == "0" -a  "$counter_1" -gt "0" ]; then
        manualbodytxt "There are no mount points without 'nosuid,nodev,noexec' options."
    else
        manualbodytxt "There are mounts without 'nosuid,nodev,noexec' options"
        manualbodytxt "Validate that correct mount options are used wherever applicable"
        if [ -n "$verbose" ]; then
            for index in "${ouputarr[@]}"; do verbosetxt "${bldwhtclr} $index$1${txtrst}"; done
        else
            manualbodytxt "Use -v option to get more details about these mount points"
        fi
    fi
}

test_5_9() {
    local testid="5.9"
    local desc="Ensure that the host's network namespace is not shared"
    local check="$testid - $desc"
    local output

    output=$(grep -irns "veth" /tmp/dobby/plugin/networking | grep $containername)

    if [ "$output" == "" ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_5_10() {
    local testid="5.10"
    local desc="Ensure that the memory usage for containers is limited"
    local check="$testid - $desc"
    local output
    local total

    output=$(cat /sys/fs/cgroup/memory/$containername/memory.limit_in_bytes)

    total=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)

    if [ "$output" == "0" -o "$output" == "-1" -o "$output" == "$total" ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_5_11() {
    local testid="5.11"
    local desc="Ensure that CPU priority is set appropriately on containers"
    local check="$testid - $desc"
    local output
    local file

    file="/sys/fs/cgroup/cpu/$containername/cpu.shares"
    if [ -f "$file" ]; then
        output=$(cat "$file")
        if [ "$output" -gt "1" -a "$output" -le "262144" ]; then
            pass "$check"
        else
            fail "$check"
            verbosetxt "${bldcynclr} Invalid CPU cgroup share value : $output $1${txtrst} "
        fi
    else
        fail "$check"
        verbosetxt "${bldcynclr} CPU cgroup is not set for the container $1${txtrst} "
    fi
}

test_5_12() {
    local testid="5.12"
    local desc="Ensure that the container's root filesystem is mounted as read only"
    local check="$testid - $desc"
    local output
    local output_1

    output=$(cat /proc/$Container_PID/mounts | grep "/ ")
    output_1=$(echo $output | awk '{ print $4}'| cut -d ',' -f 1)

    if [ "$output_1" == "ro" ]; then
        pass "$check"
        return
    fi

    fail "$check"
}

test_5_12_1() {
    local testid="5.12.1"
    local desc="Ensure that /tmp is not bind-mounted directly into the container"
    local check="$testid - $desc"
    local output

    output=$(cat /proc/$Container_PID/mounts | grep "/tmp" | awk '{print $3}')
    while read line;
    do
        if [ "$line" != "tmpfs" ]; then
            fail "$check"
            return
        fi
    done <<< "$output"

    pass "$check"
}

test_5_12_2() {
    local testid="5.12.2"
    local desc="Ensure that container rootfs directory is owned by the correct container uid/gid"
    local check="$testid - $desc"
    local read_uid
    local read_gid
    local uid
    local gid

    read_uid=$(ls -n /proc/$Container_PID/root | awk '{print $3}')
    read_gid=$(ls -n /proc/$Container_PID/root | awk '{print $4}')

    uid=$(cat /proc/$Container_PID/status | grep '^Uid:' | awk '{print $3}')
    gid=$(cat /proc/$Container_PID/status | grep '^Gid:' | awk '{print $3}')

    if [ "$read_uid" == "$uid" -a "$read_gid" == "$gid" ]; then
        pass "$check"
        return
    fi

    fail "$check"
}

test_5_12_3() {
    local testid="5.12.3"
    local desc="Containers should use the Storage plugin to provide r/w storage areas where possible"
    local check="$testid - $desc"
    local output

    output=$(cat /proc/$Container_PID/mounts | grep '/dev/loop' )
    manual "$check"
    if [ "$output" == "" ]; then
        manualbodytxt "There are no loopback storage mounts present in container"
    else
        manualbodytxt "There are the loopback storage mounts present in container. Use -v option if they are not visible"
        verbosetxt "${bldwhtclr} $output $1${txtrst}"
    fi
    manualbodytxt "Ensure that storage plugin is used to persist container data wherever applicable."
}

test_5_12_4() {
    local testid="5.12.4"
    local desc="Ensure that the rootfsPropagation is set to private"
    local check="$testid - $desc"
    local output
    local output_1

    output=$(crun --root /run/rdk/crun list | grep $containername | awk '{print $4}')
    output_1=$(cat $output/config.json | grep 'rootfsPropagation'  | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

    if [ "$output_1" == "rprivate"  ]; then
        pass "$check"
        return
    fi

    fail "$check"
}

test_5_15() {
    local testid="5.15"
    local desc="Ensure that the host's process namespace is not shared"
    local check="$testid - $desc"
    local output
    local nspid
    local pid

    pid=$(cat /proc/$Container_PID/status | grep -w 'Pid'| awk '{print $2}')
    nspid=$(cat /proc/$Container_PID/status | grep -w 'NSpid'| awk '{print $3}')

    if [ "$nspid" == "$pid" ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_5_17() {
    local testid="5.17"
    local desc="Ensure that host devices are not directly exposed to containers"
    local check="$testid - $desc"
    local output_1
    local output_2

    # First check if MKNOD is in container config, if it is not then it is safe
    # to have devices exposed
    output_1=$(crun --root /run/rdk/crun list | grep $containername | awk '{print $4}')
    output_2=$(cat $output_1/config.json | grep 'CAP_MKNOD')

    if [ -z "$output_2" ]; then
        # No CAP_MKNOD
        pass "$check"
    else
        output_1=$(cat /sys/fs/cgroup/devices/$containername/devices.list | grep  "m")
        output_2=$(cat /sys/fs/cgroup/devices/$containername/devices.list | grep  "*")

        # See https://github.com/containers/crun/pull/944 for details of default devices
        local crun_wild="c *:* m b *:* m c 136:* rwm"
        local crun_mknod="c *:* m b *:* m c 1:3 rwm c 1:8 rwm c 1:7 rwm c 5:0 rwm c 1:5 rwm c 1:9 rwm c 5:1 rwm c 136:* rwm c 5:2 rwm"

        if [[ "${output_1//[$' \n\r']/}" == "${crun_mknod//[$' \n\r']/}" && \
              "${output_2//[$' \n\r']/}" == "${crun_wild//[$' \n\r']/}" ]]; then
            warn "$check"
            verbosetxt "Only crun specified devices are exposed, but having no CAP_MKNOD in container would be safer"
        else
            fail "$check"
            verbosetxt "${bldcynclr} These are the device nodes exposed to container with * or mknod permission"
            verbosetxt "${bldwhtclr} $output_1\n$output_2$1${txtrst} "
            verbosetxt "${bldwhtclr} Only those should be avalible:\n$crun_wild\n$crun_mknod$1${txtrst} "
        fi
    fi
}

test_5_20() {
    local testid="5.20"
    local desc="Ensure that the host's UTS namespace is not shared"
    local check="$testid - $desc"
    local output_1
    local output_2
    local DobbyDaemon_PID

    DobbyDaemon_PID=$(pidof DobbyDaemon)
    output_1=$(readlink /proc/$Container_PID/ns/uts | cut -d "[" -f2- |  cut -d "]" -f1)
    output_2=$(readlink /proc/$DobbyDaemon_PID/ns/uts | cut -d "[" -f2- |  cut -d "]" -f1)

    if [ "$output_1" == "$output_2" ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_5_20_1() {
    local testid="5.20.1"
    local desc="Ensure that mount namespace is enabled"
    local check="$testid - $desc"
    local output_1
    local output_2
    local DobbyDaemon_PID

    DobbyDaemon_PID=$(pidof DobbyDaemon)
    output_1=$(readlink /proc/$Container_PID/ns/mnt | cut -d "[" -f2- |  cut -d "]" -f1)
    output_2=$(readlink /proc/$DobbyDaemon_PID/ns/mnt | cut -d "[" -f2- |  cut -d "]" -f1)

    if [ "$output_1" == "$output_2" ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_5_21() {
    local testid="5.21"
    local desc="Ensure that seccomp profile is enabled for the container"
    local check="$testid - $desc"
    local output

    output=$(grep Seccomp /proc/$Container_PID/status | awk '{print $2}')

    if [ "$output" == "0" ]; then
        fail "$check"
        verbosetxt "Seccomp is not enabled"
        return
    elif [ "$output" == "1" -o "$output" == "2" ]; then
        pass "$check"
    else
        fail "$check"
        verbosetxt "Seccomp is not enabled"
    fi
}

test_5_24() {
    local testid="5.24"
    local desc="Ensure that cgroup is defined for the container"
    local check="$testid - $desc"
    local output

    output=$(cat /proc/$Container_PID/cgroup)
    while read line;
    do
        line=$(echo $line | grep -o ':/[^"]*' | cut -d '/' -f2-)
        if [ "$line" != "$containername" ]; then
            fail "$check"
            return
        fi
    done <<< "$output"

    pass "$check"
}

test_5_24_1() {
    local testid="5.24.1"
    local desc="Ensure that GPU cgroup restrictions are enabled in supported platforms (Only supported for Mali platforms now)"
    local check="$testid - $desc"
    local output
    local file

    file="/sys/fs/cgroup/gpu/$containername/gpu.limit_in_bytes"
    if [ -f $file ]; then
        output=$(cat "$file")
        total=$(cat /sys/fs/cgroup/gpu/gpu.limit_in_bytes)

        if [ "$output" == "0" -o "$output" == "-1" -o "$output" == "$total" ]; then
            fail "$check"
            return
        fi
        pass "$check"
    else
        warn "$check"
        verbosetxt "${bldcynclr} GPU cgroup is not supported in this platform"
    fi
}

test_5_28() {
    local testid="5.28"
    local desc="Ensure that the PIDs cgroup limit is used"
    local check="$testid - $desc"
    local output

    output=$(cat /sys/fs/cgroup/pids/$containername/pids.max)

    if [ "$output" == "max" ]; then
        fail "$check"
        return
    fi

    pass "$check"
}

test_5_29() {
    local testid="5.29"
    local desc="Ensure that Dobby's default bridge "dobby0" is used"
    local check="$testid - $desc"
    local output
    local file

    file="/sys/class/net/dobby0"
    if [ -d $file ]; then
        output=$(grep -irns "veth" /tmp/dobby/plugin/networking | grep $containername)
        if [ "$output" == "" ]; then
            fail "$check"
            verbosetxt "${bldcynclr}Container is not using NAT mode networking$1${txtrst} "
            return
        else
            pass "$check"
        fi
    else
        fail "$check"
        verbosetxt "${bldcynclr}Container is not using dobby0 bridged interface$1${txtrst} "
    fi
}

test_5_31() {
    local testid="5.31"
    local desc="Ensure that the Dobby socket is not mounted inside any containers"
    local check="$testid - $desc"
    local output

    output=$(find /proc/$Container_PID/root/* -iname dobbyPty.sock 2>/dev/null)

    if [ "$output" == "" ]; then
        pass "$check"
        return
    fi

    fail "$check"
}

test_5_32() {
    local testid="5.32"
    local desc="Ensure that the noNewPrivileges  is set to true"
    local check="$testid - $desc"
    local output
    local output_1

    output=$(crun --root /run/rdk/crun list | grep $containername | awk '{print $4}')
    output_1=$(cat $output/config.json | grep 'noNewPrivileges'  | awk '{print $2}' | sed 's/,//g')

    if [ "$output_1" == "true"  ]; then
        pass "$check"
        return
    fi

    fail "$check"
}

