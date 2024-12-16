#!/bin/bash

# Variables
JFROG_HOME="/path/to/jfrog"  # Replace with your actual JFROG_HOME path
SYSTEM_YAML_PATH="$JFROG_HOME/artifactory/var/etc/system.yaml"
EC2_PUBLIC_IP="your-ec2-public-ip"  # Replace with your EC2 Public IP
DB_USERNAME="artifactory"
DB_PASSWORD="password"
DB_NAME="artifactorydb"

# Step 1: Create directories and set permissions
echo "Creating necessary directories..."
mkdir -p "$JFROG_HOME/artifactory/var/etc/"
cd "$JFROG_HOME/artifactory/var/etc/" || exit 1

# Step 2: Create the system.yaml file
echo "Creating system.yaml file..."
touch ./system.yaml
chown -R 1030:1030 "$JFROG_HOME/artifactory/var"

# Step 3: Configure database connection
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

echo "Database configuration is complete."
