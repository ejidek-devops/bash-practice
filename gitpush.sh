#!/bin/bash

# name: ejiwumi
# date: 2025
# version: 1.0.0
# About: This script will be use to push local git repo to github repo

git status
git add .

# argument for the commit message
read -p "Enter commit message: " message

# commit to local repo with message
git commit -m "$message"


