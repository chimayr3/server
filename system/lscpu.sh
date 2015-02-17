#!/usr/bin/env bash

# lscpu bash
# source
# https://github.com/karelzak/util-linux/blob/master/sys-utils/lscpu.c

# temp var
export TODO='_'

# sys path
export _PATH_SYS_SYSTEM='/sys/devices/system'
export _PATH_SYS_CPU="${PATH_SYS_SYSTEM}/cpu"
export _PATH_SYS_NODE="${_PATH_SYS_SYSTEM}/node"
export _PATH_PROC_XEN='/proc/xen'
export _PATH_PROC_XENCAP="${_PATH_PROC_XEN}/capabilities"
export _PATH_PROC_CPUINFO='/proc/cpuinfo'
export _PATH_PROC_PCIDEVS='/proc/bus/pci/devices'
export _PATH_PROC_SYSINFO='/proc/sysinfo'
export _PATH_PROC_STATUS='/proc/self/status'
export _PATH_PROC_VZ='/proc/vz'
export _PATH_PROC_BC='/proc/bc'
export _PATH_PROC_DEVICETREE='/proc/device-tree'
export _PATH_DEV_MEM='/dev/mem'

# Lookup a pattern and get the value from cpuinfo
# format is : "<pattern>   : <key>"
#
# ${1} : the pattern
function _lookup(){
  local PATTERN="${1}"
  awk -F: "/${PATTERN}/ {s=\$2} END {print s}" ${_PATH_PROC_CPUINFO}
}

# read basic informations
function _read_basicinfo(){
  export DESC_ARCH="$(uname -p)"
  export DESC_VENDOR="$(_lookup '^vendor')"
  export DESC_VENDOR="$(_lookup '^vendor_id')"
  export DESC_FAMILY="$(_lookup '^family')"
  export DESC_FAMILY="$(_lookup '^cpu family')"
  export DESC_MODEL="$( _lookup '^model')"
  export DESC_MODELNAME="$( _lookup '^model name')"
  export DESC_STEPPING="$( _lookup '^stepping')"
  export DESC_MHZ="$( _lookup '^cpu MHz')"
  export DESC_FLAGS="$( _lookup '^flags')" # x86
  export DESC_FLAGS="$( _lookup '^feature')" # s390
  export DESC_FLAGS="$( _lookup '^type')" # sparc64
  export DESC_BOGOMIPS="$( _lookup '^bogomips per cpu')" # s390
  export DESC_BOGOMIPS="$( _lookup '^bogomips')"
}

# print output
function _print_summary(){

  echo "Architecture:        ${DESC_ARCH}"
  echo "CPU op-mode(s):      ${TODO}"
  echo "Byte Order:          ${TODO}"
  echo "CPU(s):              ${TODO}"
  echo "On-line CPU(s) mask: ${TODO}"
  echo "On-line CPU(s) list: ${TODO}"
  echo "Thread(s) per core:  ${TODO}"
  echo "Core(s) per socket:  ${TODO}"
  echo "CPU socket(s):       ${TODO}"
  echo "NUMA node(s):        ${TODO}"
  echo "Vendor ID:           ${DESC_VENDOR}"
  echo "CPU family:          ${DESC_FAMILY}"
  echo "Model:               ${DESC_MODEL}"
  echo "Stepping:            ${DESC_STEPPING}"
  echo "CPU MHz:             ${DESC_MHZ}"
  echo "BogoMIPS:            ${DESC_BOGOMIPS}"
  echo "Virtualization:      ${TODO}"
  echo "L1d cache:           ${TODO}"
  echo "L1i cache:           ${TODO}"
  echo "L2 cache:            ${TODO}"
  echo "NUMA node0 CPU(s):   ${TODO}"

}

function _main(){
  _read_basicinfo
  _print_summary
}

_main ${@}
