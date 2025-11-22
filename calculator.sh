#!/bin/bash

#========================
# Name: Ejiwumi
# Date: 19th
#========================

NUM1=$1
OPE=$2
NUM2=$3

if [ $OPE = "+" ]; then
	ADD=$((NUM1 + NUM2))
	echo "$NUM1 + $NUM2 = $ADD"
elif [ $OPE = "-" ]; then
	SUB=$((NUM1 - NUM2))
	echo "$NUM1 - $NUM2 = $SUB"
elif [ $OPE = "/" ]; then
	DIV=$((NUM1 / NUM2))
	echo "$NUM1 / $NUM2 = $DIV"
elif [ $OPE = "*" ]; then
	MUL=$((NUM1 * NUM2))
	echo "$NUM1 x $NUM2 = $MUL"
else 
	echo "The Operator is not correct, input a valid operator"
fi
