#!/bin/bash
#Install docker
yum install docker -y 
systemctl start docker
systemctl enable docker
# Variables
JFROG_HOME="/opt/jfrog"  # Replace with the correct JFROG_HOME path if not set
SYSTEM_YAML_PATH="$JFROG_HOME/artifactory/var/etc/system.yaml"
DB_NAME="artifactorydb"
DB_USERNAME="artifactory"
DB_PASSWORD="password"

# Step 1: Retrieve Public IP Address
echo "Retrieving Public IP Address..."
EC2_PUBLIC_IP=$(curl -s ifconfig.me)

if [ -z "$EC2_PUBLIC_IP" ]; then
    echo "Failed to retrieve public IP. Please check your internet connection or try again."
    exit 1
fi
echo "Your Public IP Address is: $EC2_PUBLIC_IP"

# Step 2: Create JFrog Home Directory
echo "Creating JFrog Home Directory..."
mkdir -p "$JFROG_HOME/artifactory/var/etc/"

# Step 3: Create the system.yaml file
echo "Creating system.yaml file..."
touch "$SYSTEM_YAML_PATH"

# Step 4: Change ownership of JFrog Home directory
echo "Changing ownership of JFrog Home Directory..."
chown -R 1030:1030 "$JFROG_HOME/artifactory/var"

# Step 5: Configure database connection in system.yaml
echo "Configuring database connection in system.yaml..."
cat <<EOL >"$SYSTEM_YAML_PATH"
shared:
  database:
    driver: org.postgresql.Driver
    type: postgresql
    url: jdbc:postgresql://$EC2_PUBLIC_IP:5432/$DB_NAME
    username: $DB_USERNAME
    password: $DB_PASSWORD
EOL

echo "Configuration complete. system.yaml has been updated successfully."

# Step 6: Pull and Run PostgreSQL Docker Container
echo "Creating and starting PostgreSQL container..."
docker run --name postgres -itd \
  -e POSTGRES_USER="$DB_USERNAME" \
  -e POSTGRES_PASSWORD="$DB_PASSWORD" \
  -e POSTGRES_DB="$DB_NAME" \
  -p 5432:5432 \
  postgres:latest

# Verify PostgreSQL Container is running
if [ $? -eq 0 ]; then
    echo "PostgreSQL container started successfully."
else
    echo "Failed to start PostgreSQL container."
    exit 1
fi

# Step 7: Pull and Run JFrog Artifactory Docker Container
echo "Creating and starting JFrog Artifactory container..."
docker run --name artifactory -d \
  -v "$JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory" \
  -p 8081:8081 -p 8082:8082 \
  releases-docker.jfrog.io/jfrog/artifactory-oss:latest

# Verify Artifactory Container is running
if [ $? -eq 0 ]; then
    echo "JFrog Artifactory container started successfully."
else
    echo "Failed to start JFrog Artifactory container."
    exit 1
fi

echo "Script execution completed successfully!"
