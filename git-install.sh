#!/bin/bash
# Install GIT #
echo check GIT installed or not 

git --version

echo install git

sudo yum install git -y

git init /home/ec2-user/Unrealengine/

echo GIT Installation is completed
