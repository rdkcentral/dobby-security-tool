#!/bin/bash

test_3_1() {
  local testid="3.1"
  local desc="Ensure that the dobby.service file ownership is set to root:root"
  local check="$testid - $desc"
  local file

  file="/lib/systemd/system/dobby.service"
  
  if [ -f $file ]; then
    if [ "$(stat -c %u%g "$file")" -eq 00 ]; then
      pass "$check"
      return
    fi
    fail "$check Wrong ownership for $file"
    return
  fi
  
  warn "$check [ $file file is not found]"
}

test_3_2() {
  local testid="3.2"
  local desc="Ensure that dobby.service file permissions are appropriately set"
  local check="$testid - $desc"
  local file

  file="/lib/systemd/system/dobby.service"
  
  if [ -f $file ]; then
    if [ "$(stat -c %a "$file")" -le 644 ]; then
      pass "$check"
      return
    fi
    fail "$check"
    return
  fi
  
  warn "$check [ $file file is not found]"
}

test_3_3() {
  local testid="3.3"
  local desc="Ensure that dobbyPty.sock file ownership is set to root:root"
  local check="$testid - $desc"
 
    if [ "$(stat -c %u%g "/tmp/dobbyPty.sock")" -eq 00 ]; then
      pass "$check"
      return
    fi
    fail "$check"
}

test_3_4() {
  local testid="3.4"
  local desc="Ensure that dobbyPty.sock file permissions are set to 644 or more restrictive"
  local check="$testid - $desc"

    if [ "$(stat -c %a "/tmp/dobbyPty.sock")" -le 644 ]; then
      pass "$check"
      return
    fi
    fail "$check"
}

test_3_17() {
  local testid="3.17"
  local desc="Ensure that the dobby.json file ownership is set to root:root"
  local check="$testid - $desc"
  local file

  file="/etc/dobby.json"
  
  if [ -f $file ]; then
    if [ "$(stat -c %u%g "$file")" -eq 00 ]; then
      pass "$check"
      return
    fi
    fail "$check"
    return
  fi
  
  warn "$check [ $file file is not found]"
}

test_3_18() {
  local testid="3.18"
  local desc="Ensure that dobby.json file permissions are set to 644 or more restrictive"
  local check="$testid - $desc"
  local file

  file="/etc/dobby.json"
  
  if [ -f $file ]; then
    if [ "$(stat -c %a "$file")" -le 644 ]; then
      pass "$check"
      return
    fi
    fail "$check"
    return
  fi
  
  warn "$check [ $file file is not found]"
}
