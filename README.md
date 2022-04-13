
# dobby-security-tool


Dobby Security Tool is a script based tool for checking security configurations of dobby container.

It is based on CIS_Docker_Benchmark_v1.3.1 standard and influenced from docker-bench-security.

The tests are automated for each dobby containers.

Running Dobby Security Tool

git clone https://github.com/rdkcentral/dobby-security-tool.git

cd dobby-security

./dobby_security.sh -c container_name 

If required additional prints for more information, follow below command

  Ex: ./dobby_security.sh -c Netflix -v
  
  To run the individual test case, follow below command
  
  - Only run the test "5.10 - Ensure that the memory usage for containers is limited":
  
      ./dobby_security.sh -c Netflix -t test_5_10
      
  - Run all available test except the dobby_daemon_configuration group and "2.9 - Enable user namespace support":
  
      ./dobby_security.sh -c Netflix -e dobby_daemon_configuration,test_2_9
      
  - Run just the dobby_container_runtime tests except "5.9 - Ensure that the host's network namespace is not shared":
  
      ./dobby_security.sh -c Netflix -t dobby_container_runtime -e test_5_9
  
Options:

  -c  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mandatory &nbsp;&nbsp;&nbsp;&nbsp; Container name (Ensure the container is running)
  
  -e  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; Comma delimited list of specific test(s) id to exclude 
  
  -h  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; Print this help message
  
  -t  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; Comma delimited list of specific test(s) id
  
  -v  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; prints the additional prints
  


After excuted the script, you will get the output as test results summary.


![image](https://user-images.githubusercontent.com/79261622/162953578-d62afc70-2d0b-4195-bddf-2ebe53f6ec87.png)

