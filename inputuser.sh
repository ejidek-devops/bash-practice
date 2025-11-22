#!/bin/bash

#==========================
# Name: Adekunle
# Date: 19th
#==========================

read -p "Enter your Username? " USER_NAME
echo "Hello $USER_NAME"

if [ ${USER_NAME,,} = root ]; then
	echo "You are the superuser!"
else
	echo "you are a regular user"
fi
