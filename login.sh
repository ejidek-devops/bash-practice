#!/bin/bash


read -p "Enter your UserName? " USER_NAME

case ${USER_NAME,,} in 
	adekunle | administrator)
		echo "You are the boss Welcome back boss!!"
		;;
	help) 
		echo "Just input the Username dummy!!!!"
		;;
	*) 
		echo "I dont know who you are or input a valid Username!"
		;;
esac
