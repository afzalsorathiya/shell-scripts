#!/bin/bash

# AWS Access Key ID and Secret Access Key
# AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
# AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"

#user => sahil
# echo -n "Enter KEY ID: "
# read AWS_ACCESS_KEY_ID
# echo -n "Enter Secret access key: "
# read AWS_SECRET_ACCESS_KEY

AWS_ACCESS_KEY_ID="AKIAQQZKGILRDSNN7JX6"
AWS_SECRET_ACCESS_KEY="GqKkBh30vKi56+KFda79v6JsVOWzteXeUfprq9BW"


# AWS region and instance details
AWS_REGION="ap-south-1"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0f5ee92e2d63afc18"  # Replace with your desired AMI ID
INSTANCE_NAME="MyInstance"
KEY_NAME="my server name"           # Replace with your key pair name

# User password for the instance
USER_PASSWORD="Afzal@3604"

# Launch the instance
instance_id=$(aws ec2 run-instances \
  --region $AWS_REGION \
  --instance-type $INSTANCE_TYPE \
  --image-id $AMI_ID \
  --key-name $KEY_NAME \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --output json \
  --query "Instances[0].InstanceId"
)

if [ -z "$instance_id" ]; then
  echo "Failed to launch instance"
  exit 1
else
  echo "Instance $INSTANCE_NAME (ID: $instance_id) is launching..."
fi

# Wait for the instance to be running
aws ec2 wait instance-running --instance-ids $instance_id --region $AWS_REGION

# Get the public IP address of the instance
public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].PublicIpAddress" --output json --region $AWS_REGION --output text)

# SSH into the instance and set the user password
ssh -i "$KEY_NAME.pem" ec2-user@$public_ip "echo -e '$USER_PASSWORD\n$USER_PASSWORD' | sudo passwd ec2-user"

echo "Instance setup complete. Public IP: $public_ip"
