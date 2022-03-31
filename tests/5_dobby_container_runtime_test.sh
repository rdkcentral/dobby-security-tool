#!/bin/bash
test_5_3() {
	local testid="5.3"
	local desc="Ensure that Linux kernel capabilities are restricted within containers"
	local check="$testid - $desc"
	local output
	local input
	local DobbyInit_PID
	local ouputarr
	
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

        output_1=$(cat /proc/$DobbyInit_PID/mounts | grep  -E 'boot|dev|etc|lib|proc|sys|usr|bin|sbin|opt')
	input=( "/boot" "/dev" "/etc" "/lib" "/proc" "/sys" "/usr" "/bin" "/sbin" "/opt" )

	        for i in "${input[@]}"
        	do
        		var=$(echo $output_1 | grep -E "(^| )$i( |$)")
			if [ "$var" != "" ]; then
				output_2=$(cat /proc/$DobbyInit_PID/mountinfo | grep -E "(^| )$i( |$)")
				Fm_arr+=("$output_2");((fullymounted=fullymounted+1))
				output_3=$(echo $output_2 | awk '{print $6}')
	
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
		 printtxt "The following directories are mounted fully"
		 for index in "${Fm_arr[@]}"; do echo "$index"; done
		fi
		return

	else
		fail "$check"
		if [ -n "$verbose" ]; then
		 printtxt "The following directories are mounted fully in rw mode"
                 for index in "${Rw_arr[@]}"; do echo "$index"; done
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

test_5_12() {
        local testid="5.12"
        local desc="Ensure that the container's root filesystem is mounted as read only"
        local check="$testid - $desc"
        local output
        local output_1
	local DobbyInit_PID

        DobbyInit_PID=$(ps -fe | grep DobbyInit | grep $containername | awk '{print $2}')
        output=$(cat /proc/$DobbyInit_PID/mounts | grep "/ ")
        output_1=$(echo $output | awk '{ print $4}')

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

test_5_15() {
	local testid="5.15"
	local desc="Ensure that the host's process namespace is not shared"
	local check="$testid - $desc"
	local output
  	local nspid
	local pid

	output=$(DobbyTool info $containername | jsonValue nsPid)
	nspid=$(echo $output | awk '{ print $1}')
		
	output=$(DobbyTool info $containername | jsonValue pid)
	pid=$(echo $output | awk '{ print $1}')

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
    	fi
   		 fail "$check"  
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
        local desc="Ensure that GPU cgroup restrictions are enabled in supported platforms (Only supported for Mali patforms)"
        local check="$testid - $desc"
        local output

        output=$(DobbyTool info $containername | grep "gpu")
        if [ "$output" == "" ]; then
                fail "$check"
                return
        fi

        pass "$check"

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
	output=$(find /proc/$DobbyInit_PID/root/* -iname dobbyPty.sock | grep -v find)
	
    if [ "$output" == "" ]; then
      pass "$check"
      return
    fi
    fail "$check"

}

