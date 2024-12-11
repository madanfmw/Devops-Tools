import boto3
import os
import sys
from botocore.exceptions import ClientError

def create_key_pair(ec2, key_name):
    try:
        ec2.describe_key_pairs(KeyNames=[key_name])
        print(f"Key Pair '{key_name}' already exists. Using the existing key.")
    except ClientError:
        print(f"Key Pair '{key_name}' does not exist. Creating a new one...")
        key_pair = ec2.create_key_pair(KeyName=key_name)
        with open(f"{key_name}.pem", "w") as file:
            file.write(key_pair['KeyMaterial'])
        os.chmod(f"{key_name}.pem", 0o400)
        print(f"New Key Pair created and saved as {key_name}.pem")

def get_or_create_security_group(ec2, group_input):
    security_group_id = None

    # Check if the input is a Security Group Name or ID
    try:
        if group_input.startswith("sg-"):
            # Treat input as Security Group ID
            response = ec2.describe_security_groups(GroupIds=[group_input])
            security_group_id = response['SecurityGroups'][0]['GroupId']
            print(f"Security Group ID '{group_input}' found. Using the existing group.")
        else:
            # Treat input as Security Group Name
            response = ec2.describe_security_groups(GroupNames=[group_input])
            security_group_id = response['SecurityGroups'][0]['GroupId']
            print(f"Security Group Name '{group_input}' found. Using the existing group.")
    except ClientError as e:
        print(f"Security Group '{group_input}' does not exist. Creating a new one...")
        response = ec2.create_security_group(GroupName=group_input, Description="Security group for EC2 instance")
        security_group_id = response['GroupId']
        ec2.authorize_security_group_ingress(GroupId=security_group_id, IpProtocol="tcp", FromPort=22, ToPort=22, CidrIp="0.0.0.0/0")
        print(f"New Security Group created with ID: {security_group_id}")

    return security_group_id

def main():
    print("""
!!! Welcome to HINTechnologies !!!

As part of DevOps Training, this script will help you create an EC2 Instance!
""")

    # AWS Session
    region = input("Enter AWS Region (default: us-east-1): ") or "us-east-1"
    session = boto3.Session(region_name=region)
    ec2 = session.client('ec2')

    # Key Pair
    key_name = input("Enter Key Pair name (if it exists, it will be used): ")
    create_key_pair(ec2, key_name)

    # Security Group
    group_input = input("Enter Security Group name or ID (if it exists, it will be used): ")
    security_group_id = get_or_create_security_group(ec2, group_input)

    # Instance Type Selection
    print("Select Instance Type:")
    print("1 - [2vCPU and 2GiB RAM - t3.small] TomcatServer ")
    print("2 - [2vCPU and 4GiB - t3.medium] Jenkins_Server | Sonarqube | Jfrog | Docker | K8S ")
    print("3 - [2vCPU and 8GiB - t3.large] Kubernetes Setup ")
    instance_type_choice = input("Enter the number corresponding to the desired instance type: ")

    # Map user choice to the instance type
    instance_type_map = {
        "1": "t3.small",
        "2": "t3.medium",
        "3": "t3.large"
    }
    instance_type = instance_type_map.get(instance_type_choice, "t3.small")  # Default to t3.small if invalid input

    print(f"Selected Instance Type: {instance_type}")

    # AMI ID (default value)
    ami_id = "ami-053b12d3152c0cc71"
    print(f"Using default AMI ID: {ami_id}")

    # Instance Name
    instance_name = input("Enter Name for the EC2 Instance: ")

    # Storage
    storage_size = input("Enter Storage Size in GB (default: 8): ") or "8"

    # User Data File (default: temp-swap-setup-file.txt)
    default_user_data_file = "temp-swap-setup-file.txt"
    if os.path.isfile(default_user_data_file):
        user_data_file = default_user_data_file
        print(f"Using default User Data file: {user_data_file}")
    else:
        user_data_file = input(f"Default User Data file '{default_user_data_file}' not found. Please enter the full path to the User Data file: ")
        if not os.path.isfile(user_data_file):
            print("Error: The specified User Data file does not exist.")
            sys.exit(1)

    # Instance Count
    instance_count = int(input("How many instances do you want to create? (default: 1): ") or "1")

    # Read User Data
    with open(user_data_file, 'r') as file:
        user_data = file.read()
    print("User Data script found. Including it in the instance creation.")

    # Launch EC2 Instance
    print(f"Launching {instance_count} EC2 instance(s)...")
    block_device_mappings = [{
        "DeviceName": "/dev/xvda",
        "Ebs": {
            "VolumeSize": int(storage_size),
            "DeleteOnTermination": True,
            "VolumeType": "gp2"
        }
    }]

    try:
        instances = ec2.run_instances(
            ImageId=ami_id,
            MinCount=instance_count,
            MaxCount=instance_count,
            InstanceType=instance_type,
            KeyName=key_name,
            SecurityGroupIds=[security_group_id],
            BlockDeviceMappings=block_device_mappings,
            UserData=user_data,
        )

        instance_ids = [instance['InstanceId'] for instance in instances['Instances']]
        print(f"Successfully launched EC2 instance(s) with ID(s): {', '.join(instance_ids)}")

        # Tagging Instances
        ec2.create_tags(Resources=instance_ids, Tags=[{"Key": "Name", "Value": instance_name}])
        print("Added Name tag to the instance(s).")

        # Wait for Instances to be Running
        print("Waiting for instance(s) to enter running state...")
        waiter = ec2.get_waiter('instance_running')
        waiter.wait(InstanceIds=instance_ids)
        print("Instance(s) are now running.")

        # Fetch Public IPs
        response = ec2.describe_instances(InstanceIds=instance_ids)
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                print(f"Instance ID: {instance['InstanceId']}, Public IP: {instance.get('PublicIpAddress')}")

    except Exception as e:
        print(f"Error launching EC2 instance(s): {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
