#! /bin/bash
  
# Json Value parsing script  
jsonValue() {
KEY=$1
num=$2
awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

# Input validation checking
input_valid() {
local output

output=$(DobbyTool info $containername |grep "error" | awk '{print $1}')

if [ "$output" == "" ]; then
	echo "Container is running"
else
	printtxt "${bldmgnclr} Failed to find the container \n Please enter valid container name' Ex:./dobby_security.sh -c Netflix [OPTIONS] ${txtrst}\n"
	exit 1
fi
}

host_configuration() {
test_1
test_1_2_2
}

dobby_daemon_configuration() {
test_2
test_2_1
test_2_9
}

dobby_daemon_configuration_files() {
test_3
test_3_1
test_3_2
test_3_3
test_3_4
test_3_17
test_3_18
}

dobby_container_images() {
test_4
test_4_1
test_4_8
}

dobby_container_runtime() {
test_5
test_5_1
test_5_3
test_5_5
test_5_5_1
test_5_9
test_5_10
test_5_12
test_5_12_1
test_5_12_2
test_5_12_3
test_5_15
test_5_17
test_5_20
test_5_20_1
test_5_21
test_5_24
test_5_24_1
test_5_24_2
test_5_28
test_5_29
test_5_31
}

all() {
host_configuration
dobby_daemon_configuration
dobby_daemon_configuration_files
dobby_container_images
dobby_container_runtime
}