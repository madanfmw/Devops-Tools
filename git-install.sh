#!/bin/bash
# Install GIT #
echo check GIT installed or not 

git --version

echo install git

sudo yum install git -y

git init /home/ec2-user/Urealengine/

echo GIT Installation is completed
