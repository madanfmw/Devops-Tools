#!/bin/bash

# This script installs Maven, Jenkins, and Docker on an Ubuntu server

# Update package list and install dependencies
echo "Updating package list and installing dependencies..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    lsb-release \
    gnupg2 \
    fontconfig openjdk-17-jre \
    wget \
    unzip

# Install Maven
echo "Installing Maven..."
sudo apt install -y maven

# Verify Maven installation
echo "Maven version:"
mvn -v

# Install Docker
echo "Installing Docker..."
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker stable repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt update -y

# Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
echo "Docker version:"
docker --version

# Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Install Jenkins
echo "Installing Jenkins..."

# Add Jenkins repository and key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add the Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index
sudo apt update -y

# Install Jenkins
sudo apt install -y jenkins

# Start Jenkins service
echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Display Jenkins status
echo "Jenkins status:"
sudo systemctl status jenkins

# Display Jenkins setup info
echo "Jenkins is installed. To complete the setup, open your browser and visit http://<your-server-ip>:8080"
echo "Retrieve Jenkins Password"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

########################  Successfully Installed Maven, Jenkins, Dockers and Running ########################################
