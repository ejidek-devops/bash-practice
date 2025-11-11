#!/bin/bash

# About: This script will be use to push local git repo to github repo

git status
git add .

# argument for the commit message
message=$1

# commit to local repo with message
git commit -m "$message"


