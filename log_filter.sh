#!/bin/bash

#Global Var
file_name=null

cleanup(){ #removes tmp and blank files from the working dir
    rm -rf *.tmp
    find  . -maxdepth 1 -type f -empty -exec rm "{}" \;
}

filter_http_port(){
    #some local vars
    output_file_name="${file_name%_*}" #gets the timestamp from the input file
    mode=$1

    case $mode in
    1) #http
        filter_pattern="80/open/tcp"
        f_name_suffix="_http-online-hosts.txt"
        ;;
    2) #ftp
        filter_pattern="21/open/tcp"
        f_name_suffix="_ftp-online-hosts.txt"
        ;;
    3) #ssh
        filter_pattern="22/open/tcp"
        f_name_suffix="_ssh-online-hosts.txt"
        ;;
    4) #telnet
        filter_pattern="23/open/tcp"
        f_name_suffix="_telnet-online-hosts.txt"
        ;;
    esac
    output_file_name+=$f_name_suffix #concatenates the suffix to the name

    #filters lines from the input
    grep $filter_pattern $file_name > temp_file.tmp
    #filters only the IP addresses, remove duplicates
    awk '{print $2}' temp_file.tmp > temp_file2.tmp
    uniq temp_file2.tmp > temp_file3.tmp
    mv temp_file3.tmp $output_file_name
}

menu(){
    echo -n "[INFO] This script is only enabled to filter the default ports"
    echo "(e.g. 21, 22, 23 & 80)"
    echo "Please, enter the file name you want to read from (i.e. the .log file)"
    echo -n ">> "
    read f_name
    file_name=$f_name

    filter_http_port "1"
    filter_http_port "2"
    filter_http_port "3"
    filter_http_port "4"

    cleanup
}

#Execution
menu
exit