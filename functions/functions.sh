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