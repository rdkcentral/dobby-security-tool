# Mount Flags
In this chapter we will describe what each flag does. To make the decision easier if it is needed in some place.

## NOEXEC
Blocks ability of executing files on this partition. Can be safely added to devices as linux kernel only allows execution of normal files, not block or character files.<br>
**Warning** this can be avoided if we mount location without `NOEXEC` inside `NOEXEC` i.e. we have `/tmp` with `NOEXEC`, and `/opt` without `NOEXEC`, if we create `/opt/mydata` and mount it inside `/tmp/mydata` then even though `/tmp` couldn't execute files in `/tmp/mydata` it will be possible to execute something.

## NOSUID
Mounted space will ignore bits SUID  (set user ID)  and SGID (set group ID). For more details check section **File Flags**. As this is makes sense only during execution, if we have `NOEXEC` flag anywhere we should be able to safely add `NOSUID`.

## NODEV
Denies using devices in selected partition. This is probably easiest one as every other point than `/dev` (and its subdirectories) should be able to safely have this flag.


# File Flags
To better understand `NOSUID` flag here is description what file flags will be disabled by having it set.

## SUID
This bits allows file to be executed with permissions of the owner regardless who is executing them. You can find it out because it will have "s" instead "x" in owner permission field.
```
-rwsr-xr-x    1 root     root         14084 Jun  1 00:04 /usr/bin/expiry
```

## SGID
This bits allow file to be executed with permissions of the group regardless who is executing them. You can find it out because it will have "s" instead "x" in group permission field.
```
-rwxr-sr-x    1 root     root         12121 Jun  9 09:01 /usr/bin/example
```

## Sticky bit
You can find it out because it will have "t" instead "x" in user permission field. If it is applied to directory, only the owner of the file can remove files inside it (usually used for `/tmp` directory). If applied to file it was (on older systems, as this is rather depracated feature) saving program text file into swap to increase loading time.
```
drwxrwxrwt  102 root     root      4840 Jun 10 11:32 /tmp
```
Iteresting enough the `sticky bit` logic is "reversed" compared to others in regards to safety, while having `SUID` or `SGID` set makes file less safe (elevating permissions), having sticky bit set makes directory safer (as it reduces amount of people able to delete file).


# Guidelines

## Introduction
This section is designed to help decide whether some flags are correct in regards to most common directories. We explain here why something should or shouln't be generaly safe. As always with manual test final decision stays on the tester.


## Mount points

### /[...]/rootfs_dobby
This is container rootfs, should have `NODEV`, and probably also `NOSUID`. We want to be able to ship some execute files so we should allow exec.

### /dev
Obviously there cannot be `NODEV` flag,  `NOEXEC` can be safely added to devices as linux kernel only allows execution of normal files, not block or character files. `NOSUID` should be safe to have there as we will not exectute so we don't need to elevate privlidges during execution. Same logic applies to subdirectories.

### /lib /bin /sbin /usr
All of those would be better to be mounted per-app rather than whole directory, but in the sense they are there to have some exectuables, so `NODEV` and `NOSUID` should be set, but `NOEXEC` should **NOT** be set

### /proc
We should be safe with all `NOSUID`, `NOEXEC` and `NODEV`, as it only containes informations about processes, no devices or executables

### Summary table
This table summarise what was said in Mount points text.

Y - Yes flags needs to be there.<br>
N - No flag cannot be there.<br>
? - Probably should be but it depends.

| Directory             | NOSUID | NODEV | NOEXEC |
|-----------------------|:------:|:-----:|:------:|
| /[ ... ]/rootfs_dobby | ?      | Y     | N      |
| /dev                  | Y      | N     | Y      |
| /lib /bin /sbin /usr  | Y      | Y     | N      |
| /proc                 | Y      | Y     | Y      |