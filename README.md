# dobby-security-tool

## Introduction

Dobby Security Tool is a script based tool for checking security configurations of dobby container.

It is based on CIS_Docker_Benchmark_v1.3.1 standard and influenced from docker-bench-security.

The tests are automated for each dobby containers.

## Running Dobby Security Tool

```
git clone https://github.com/rdkcentral/dobby-security-tool.git
cd dobby-security-tool
./dobby_security.sh -c container_name 
```

If required additional prints for more information, follow below command i.e.:

```
./dobby_security.sh -c Netflix -v
```
  
## Runing sub-sets of tests

To run the individual test case, follow below commands:
  
  - Only run the test "5.10 - Ensure that the memory usage for containers is limited":
  
    ``` 
    ./dobby_security.sh -c Netflix -t test_5_10
    ```
      
  - Run all available test except the dobby_daemon_configuration group and "2.9 - Enable user namespace support":
    ```
    ./dobby_security.sh -c Netflix -e dobby_daemon_configuration,test_2_9
    ```
      
  - Run just the dobby_container_runtime tests except "5.9 - Ensure that the host's network namespace is not shared":
    ```
    ./dobby_security.sh -c Netflix -t dobby_container_runtime -e test_5_9
    ```
  
## Options
Dobby Security Tool supports following parameters:

| param | optional  | description                                            |
|:-----:|:---------:|--------------------------------------------------------|
| -c    | mandatory | Container name (Ensure the container is running)       |
| -e    | optional  | Comma delimited list of specific test(s) id to exclude |
| -h    | optional  | Print this help message                                |
| -t    | optional  | Comma delimited list of specific test(s) id            |
| -v    | optional  | Prints the debug messages                              |

## Expected result

After excuted the script, you will get the output as test results summary.
![11_1](https://user-images.githubusercontent.com/79261622/167787844-62a2d737-4c45-478e-a5ec-0e543e3c5cb9.png)


