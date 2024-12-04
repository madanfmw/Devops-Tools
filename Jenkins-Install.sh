#!/bin/bash

# Update the system
echo "Updating system packages..."
sudo yum update -y

# Install Java (Amazon Linux 2 uses Amazon Corretto 8/11 as the default JDK)
echo "Installing Java..."
sudo dnf install java-17-amazon-corretto -y

# Verify Java installation
echo "Verifying Java installation..."
java -version

# Add Jenkins repository and import the Jenkins key
echo "Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Update the system again to include Jenkins repository
echo "Updating system packages for Jenkins..."
sudo yum update -y

# Install Jenkins
echo "Installing Jenkins..."
sudo yum install jenkins -y

# Start and enable Jenkins service
echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Verify Jenkins status
echo "Checking Jenkins status..."
sudo systemctl status jenkins

# Open the necessary ports in the firewall
echo "Configuring the firewall to allow Jenkins (port 8080)..."
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Display initial Jenkins admin password
echo "Displaying initial Jenkins admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "Jenkins installation completed. You can access Jenkins at: http://<your-server-ip>:8080"
