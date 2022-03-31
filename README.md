# dobby-security-tool


Dobby Security Tool is a script based tool for checking security configurations of dobby container.

It is based on CIS_Docker_Benchmark_v1.3.1 standard and influenced from docker-bench-security.

The tests are automated for each dobby containers.

Running Dobby Security Tool

git clone https://github.com/rdkcentral/dobby-security-tool.git

cd dobby-security

./dobby-security.sh -c container_name 

Ex: ./dobby-security.sh -c Netflix 

If required additional prints for more information, follow below command

  Ex: ./dobby-security.sh -c Netflix -v
  
  For help message, follow the below command
  
  Ex: ./dobby-security.sh -h
  
Options:

  -b &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; Do not print colors  
  
  -c  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mandatory &nbsp;&nbsp;&nbsp;&nbsp; Container name (Ensure the container is running)
  
  -h  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; Print this help message
  
  -v  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; optional &nbsp;&nbsp;&nbsp;&nbsp; prints the additional prints
  


After excuted the script, you will get the output as test results summary.
![image](https://user-images.githubusercontent.com/79261622/161053861-14fe111c-88a4-42d7-b7df-c5f3614b7875.png)


