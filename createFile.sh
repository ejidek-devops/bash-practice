#!/bin/bash

# =========================
# name: ejiwumi
# date: 15th
# version: 1.0.0
# about: will be use to create a file
# =====================================


# ask for file name
 read -p "input the file name: " filename

#create the file
 touch $filename

# add permmision to the file
 chmod +x $filename
