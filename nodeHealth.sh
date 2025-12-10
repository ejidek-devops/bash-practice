#!/bin/bash

#==========================
# Name: Adekunle
#======================

echo "storage health"
df -h
echo "=========================="

echo "number of system core"
nproc
echo" ========================="

echo "process running on the system"
ps -ef
echo "============================"

echo "currently used ram and what is free"
free -h
