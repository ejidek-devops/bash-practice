#!/bin/bash

MY_FIRST_ARRAY=(one two three four five six)

for item in ${MY_FIRST_ARRAY[@]}
do 
	echo -n $item | wc -c;
done
