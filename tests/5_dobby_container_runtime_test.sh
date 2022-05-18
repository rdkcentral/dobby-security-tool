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
        local DobbyInit_PID
	local FILE

        FILE="/sys/module/apparmor/parameters/enabled"
	if [ -f $FILE ]; then
                DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
                output_1=$(cat /sys/module/apparmor/parameters/enabled)
                if [ "$output_1" == "Y" ]; then
                        output_2=$(cat /proc/$DobbyInit_PID/attr/current | grep -E 'complain|enforce')
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
	local DobbyInit_PID
	local ouputarr
	local status
	
	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	
	status=$(cat /proc/$DobbyInit_PID/status | grep CapPrm | awk '{print $2}')
	output=$(capsh --decode=$status | sed 's/.*=//g')
	input=( cap_net_raw cap_dac_read_search cap_sys_module cap_sys_admin cap_sys_ptrace )
	IFS=','
	read -a ouputarr <<<"$output"
	#accessing each element of array
	for i in "${!ouputarr[@]}";
	do
		for j in "${!input[@]}";
		do
			if [ "${input[$j]}" == "${ouputarr[$i]}" ]; then
				fail "$check"
				return
			elif [ "${input[$j]}" == "${ouputarr[$i]}" ]; then
				fail "$check"
				return
			elif [ "${input[$j]}" == "${ouputarr[$i]}" ]; then
				fail "$check"
				return
			elif [ "${input[$j]}" == "${ouputarr[$i]}" ]; then
				fail "$check"
				return
			fi
		done
	done
	pass "$check"
}

test_5_5() {
        local testid="5.5"
        local desc="Ensure sensitive host system directories are not mounted on containers"
        local check="$testid - $desc"
        local output_1
	local output_2
	local output_3
	local var
        local DobbyInit_PID
	local readwrite=0
	local fullymounted=0 
	

	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')

	output=$(cat /proc/$DobbyInit_PID/mounts | grep -E 'ext|fat|sqaushfs')
	#(considering only *ext*, *fat*, *squash* filesystem types	
        
	output_1=$(echo $output| grep  -E 'boot|dev|etc|lib|proc|sys|usr|bin|sbin|opt')
	input=( "/boot" "/dev" "/etc" "/lib" "/proc" "/sys" "/usr" "/bin" "/sbin" "/opt" )

	        for i in "${input[@]}"
        	do
        		var=$(echo $output_1 | grep -E "(^| )$i( |$)")
			if [ "$var" != "" ]; then
				output_2=$(cat /proc/$DobbyInit_PID/mountinfo | grep -E "(^| )$i( |$)")
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
		if [ -n "$verbose" ]; then
			printf "%b\n" "${bldcynclr} The following directories are mounted fully in ro mode$1${txtrst} "
			for index in "${Fm_arr[@]}"; do printf "%b\n" "${bldwhtclr} $index $1${txtrst}"; done
		fi
		return

	else
		fail "$check"
		if [ -n "$verbose" ]; then
			printf "%b\n" "${bldcynclr} The following directories are mounted fully in rw mode$1${txtrst} "
                	for index in "${Rw_arr[@]}"; do printf "%b\n" "${bldwhtclr} $index $1${txtrst}"; done
                fi

	fi
}

test_5_5_1() {

        local testid="5.5.1"
        local desc="Ensure nosuid,nodev,noexec options are present in mount"
        local check="$testid - $desc"
        local output
        local DobbyInit_PID
	local counter_1=0
	local counter_2=0
	local check_1
	local check_2
	local check_3
        local Flag_1
        local Flag_2
        local Flag_3
	local ouputarr

	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
        output=$(cat /proc/$DobbyInit_PID/mountinfo)
        while read line;
        do
                check_1=$(echo $line | grep nosuid)

                if [ "$check_1" == "" ]; then
                        Flag_1=0
                else
                        Flag_1=1
                fi

                check_2=$(echo $line | grep nodev)
                if [ "$check_2" == "" ]; then
                        Flag_2=0
                else
                        Flag_2=1
                fi

                check_3=$(echo $line | grep noexec)
                if [ "$check_3" == "" ]; then
                        Flag_3=0
                else
                        Flag_3=1
                fi

                if [ "$Flag_1" == "1" -a "$Flag_2" == "1" -a "$Flag_3" == "1" ]; then
			counter_1=$((counter_1+1))                       
                else
			counter_2=$((counter_2+1))
                        line=$(echo $line | grep -o '/[^"]*')
                        ouputarr+=("$line")
                fi
	done <<< "$output"
	
	if [ "$counter_2" == "0" -a  "$counter_1" -gt "0" ]; then
		 printf "%b\n" "${bldmgnclr}[MANUAL] $check \n${bldcynclr} There are no mount points without 'nosuid,nodev,noexec' options.$1${txtrst} "

	else
	
		if [ -n "$verbose" ]; then
			printf "%b\n" "${bldmgnclr}[MANUAL] $check \n${bldcynclr} These are the mounts without 'nosuid,nodev,noexec' options$1${txtrst} "
			printf "%b" "${bldcynclr} Validate that correct mount options are used wherever applicable"
        		for index in "${ouputarr[@]}"; do printf "%b" "${bldwhtclr} $index\n$1${txtrst}"; done
		else
			printf "%b\n" "${bldmgnclr}[MANUAL] $check ${bldcynclr}\n There are mount points without 'nosuid,nodev,noexec' options$1${txtrst} "
			printf "%b\n" "${bldcynclr} Validate that correct mount options are used wherever applicable."\
			" Use -v option to get more details about these mount points$1${txtrst}"
		fi


	fi
	totalmanual=$((totalmanual+1))
	
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

test_5_12() {
        local testid="5.12"
        local desc="Ensure that the container's root filesystem is mounted as read only"
        local check="$testid - $desc"
        local output
        local output_1
	local DobbyInit_PID

        DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
        output=$(cat /proc/$DobbyInit_PID/mounts | grep "/ ")
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
	local DobbyInit_PID
	local output

	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	output=$(cat /proc/$DobbyInit_PID/mounts | grep "/tmp" | awk '{print $3}')
	 
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
	local DobbyInit_PID
	local read_uid
	local read_gid
	local uid
	local gid

        DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
        
	read_uid=$(ls -n /proc/$DobbyInit_PID/root | awk '{print $3}')
        read_gid=$(ls -n /proc/$DobbyInit_PID/root | awk '{print $4}')
	
	uid=$(cat /proc/$DobbyInit_PID/status | grep '^Uid:' | awk '{print $3}')
	gid=$(cat /proc/$DobbyInit_PID/status | grep '^Gid:' | awk '{print $3}')

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
        local DobbyInit_PID
	local output

	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	output=$(cat /proc/$DobbyInit_PID/mounts | grep '/dev/loop' )
	
	if [ "$output" == "" ]; then
                printf "%b\n" "${bldmgnclr}[MANUAL] $check ${bldcynclr}\n There are no loopback storage mounts present in container"
		printf "%b\n" " Ensure that storage plugin is used to persist container data wherever applicable.$1${txtrst}"
        else
		if [ -n "$verbose" ]; then
			printf "%b\n" "${bldmgnclr}[MANUAL] $check ${bldcynclr}\n These are the loopback storage mounts present in container"
        		printf "%b\n" "${bldwhtclr} $output"
			printf "%b" "${bldcynclr} Validate that storage plugin is used to persist container data wherever applicable.$1${txtrst}\n"
		else
        		printf "%b\n" "${bldmgnclr}[MANUAL] $check ${bldcynclr}\n There are loopback storage mounts present in container"
        		printf "%b\n" "${bldcynclr} Validate that storage plugin is used to persist container data wherever applicable."\
			" Use -v option to get more details$1${txtrst} "
	
		fi
	fi

	totalmanual=$((totalmanual+1))
}
test_5_15() {
	local testid="5.15"
	local desc="Ensure that the host's process namespace is not shared"
	local check="$testid - $desc"
	local output
  	local nspid
	local pid
	
	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	pid=$(cat /proc/$DobbyInit_PID/status | grep -w 'Pid'| awk '{print $2}')
	nspid=$(cat /proc/$DobbyInit_PID/status | grep -w 'NSpid'| awk '{print $3}')
    
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

	output_1=$(cat /sys/fs/cgroup/devices/$containername/devices.list | grep  "m")
        output_2=$(cat /sys/fs/cgroup/devices/$containername/devices.list | grep  "*")

    	if [ "$output_1" == "" -a  "$output_2" == "" ]; then
        	pass "$check"
      		return
    	else
		fail "$check"  
		if [ -n "$verbose" ]; then
			printf "%b\n" "${bldcynclr} These are the device nodes exposed to container with * or mknod permission"
                	printf "%b\n" "${bldwhtclr} $output_1$output_2$1${txtrst} "
		fi
	fi

}

test_5_20() {
	
	local testid="5.20"
        local desc="Ensure that the host's UTS namespace is not shared"
        local check="$testid - $desc"
        local output_1
        local output_2
	local DobbyInit_PID
	local DobbyDaemon_PID
	
	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	DobbyDaemon_PID=$(pidof DobbyDaemon)
	output_1=$(readlink /proc/$DobbyInit_PID/ns/uts | cut -d "[" -f2- |  cut -d "]" -f1)
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
        local DobbyInit_PID
        local DobbyDaemon_PID

        DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
        DobbyDaemon_PID=$(pidof DobbyDaemon)
        output_1=$(readlink /proc/$DobbyInit_PID/ns/mnt | cut -d "[" -f2- |  cut -d "]" -f1)
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
        local DobbyInit_PID

        DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
        output=$(grep Seccomp /proc/$DobbyInit_PID/status | awk '{print $2}')

        if [ "$output" == "0" ]; then
        	fail "$check"
                if [ -n "$verbose" ]; then
                	printtxt "Seccomp is not enabled"
                fi
                return
	elif [ "$output" == "1" -o "$output" == "2" ]; then
		pass "$check"
	else
		fail "$check"
		if [ -n "$verbose" ]; then
                        printtxt "Seccomp is not enabled"
                fi
	fi

}
test_5_24() {

	local testid="5.24"
        local desc="Ensure that cgroup is defined for the container"
        local check="$testid - $desc"
	local DobbyInit_PID
	local output

        DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
	output=$(cat /proc/$DobbyInit_PID/cgroup)
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
        local desc="Ensure that CPU cgroup restrictions are enabled"
        local check="$testid - $desc"
	local output
	
	output=$(DobbyTool info $containername | grep  -E 'cpu|percpu') 
	if [ "$output" == "" ]; then
		fail "$check"
		return
	fi
	
	pass "$check"

}

test_5_24_2() {

        local testid="5.24.2"
        local desc="Ensure that GPU cgroup restrictions are enabled in supported platforms (Only supported for Mali platforms now)"
        local check="$testid - $desc"
        local output
	local FILE
	

	FILE="/sys/fs/cgroup/gpu/$containername/gpu.limit_in_bytes"
	if [ -f $FILE ]; then
		output=$(cat /sys/fs/cgroup/gpu/$containername/gpu.limit_in_bytes)
        	total=$(cat /sys/fs/cgroup/gpu/gpu.limit_in_bytes)

        	if [ "$output" == "0" -o "$output" == "-1" -o "$output" == "$total" ]; then
          		fail "$check"
         		return
        	fi
          	pass "$check"
	else
		warn "$check"
		if [ -n "$verbose" ]; then
			printf "%b\n" "${bldcynclr} GPU cgroup is not supported in this platform"
		fi
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
  
	output=$(brctl show | grep dobby0 | awk '{ print $1}')
    
    	if [ "$output" == "dobby0" ]; then
    		pass "$check"
      		return
    	fi
    	fail "$check"
}

test_5_31() {
	local testid="5.31"
        local desc="Ensure that the Dobby socket is not mounted inside any containers"
        local check="$testid - $desc"
        local output
	local DobbyInit_PID

	DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')	
	output=$(find /proc/$DobbyInit_PID/root/* -iname dobbyPty.sock 2>/dev/null)
	
    	if [ "$output" == "" ]; then
      		pass "$check"
      		return
    	fi	
    	fail "$check"

}

