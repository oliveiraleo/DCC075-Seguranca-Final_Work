#!/bin/bash

#Global Vars
ip=null
net_mask=null
cidr_addr=null
ports=null

# NOTE: Main menus based on: https://www.geeksforgeeks.org/menu-driven-shell-script/
check_super_user(){
    if [ "$EUID" -ne 0 ]
    then
        echo "[ERROR] Failed to get super user permissions"
        echo "[INFO] Root permissions are required in order to run the port scan"
        echo "Please, run this script as root"
        exit
    fi
}

step_1(){
    echo "[INFO] You are about to begin scanning an entire subnet!"
    subnet_select
    port_select
}

subnet_select(){
    echo "Please enter the desired network IP address"
    echo -n ">> "
    read input_ip_addr
    ip=$input_ip_addr
    echo "Now please enter the desired Network Mask CIDR number (e.g. use 24 for /24)"
    echo -n ">> "
    read input_mask
    net_mask=$input_mask
    cidr_addr=$ip/$net_mask
    # echo "$cidr_addr" #DEBUG
}

port_select(){
    echo "Do you want to choose the ports?"
    echo "1. No, use the default (21, 22, 23 & 80)"
    echo "2. Yes, I wanna customize the scan"
    echo "0. Cancel and exit"
    echo -n ">> "
    read input_ports_option
    case $input_ports_option in
    0)  echo "User asked to exit... Bye!"
        exit;;
    1)  echo "[INFO] Using default port config"
        ports="21,22,23,80"
        ;;
    2)  echo "Enter the ports to scan, separated by commas (e.g. 21,22,80)"
        echo -n ">> "
        read input_ports
        echo "[INFO] Using the ports: $input_ports"
        ports=$input_ports
        ;;
    *)  echo "[ERROR] Invalid option"
        port_select;;
    esac
}

step_2(){
    echo -e "\n[INFO] Ready to start the scan"
    echo "[INFO] Displaying current configuration"
    echo "[INFO] Target IP subnet range: $cidr_addr"
    echo "[INFO] Selected ports: $ports"
    echo -e "[INFO] Remember, one packet will be sent for each tested port,\nthis might trigger some Firewall/IPS/IDS systems"
    echo "Press ENTER to continue..."
    read input_start

    if [[ -n "$input_start" ]]
    then
        echo "[ERROR] You don't need to write anything... Try again"
        step_2
    else
        echo "[INFO] Performing the port scan..."
        scanner
    fi

    exit
}

scanner(){
    scantime=`date +"%Y-%m-%d_%H-%M-%S"`
    name_suffix="_port-scan.log"
    file_name="$scantime$name_suffix"
    # Options used
    # -sS: SYN Stealth
    # -p: ports
    # --open: only displays open ports
    # --randomize-hosts: avoid scanning consecutive IPs
    # --scan-delay: adds a delay before each probe
    # --max-rate: limits the number of sent packets per second
    # -oG: grepable output (https://nmap.org/book/output-formats-grepable-output.html)
    # 1>/dev/null: suppresses all console output
    nmap -sS -p $ports $cidr_addr --open --randomize-hosts --scan-delay 2s --max-rate 10 -oG $file_name 1>/dev/null
    echo "[INFO] Saved the output to $file_name"
    echo "[INFO] Port scan done"
}

# main_menu
check_super_user
step_1 #user config
step_2 #information gathering (scan)
