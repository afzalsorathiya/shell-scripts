#!/bin/bash
# Define your Hetzner API token
# echo -n "Enter Api Token: "
# read API_TOKEN

# # Define server parameters
# echo -n "Enter Server name: "
# read SERVER_NAME
# echo -n "Enter Server type: "
# read SERVER_NAME
# echo -n "Enter OS Image: "
# read IMAGE
# echo -n "Enter Password: "
# read PASSWORD
# Define server parameters
API_TOKEN="ryvL897s7uxhdjcDv9khygLmsrf7ITaTrwPjAduaFdMWwGLdSzpnNtPGTtVmoZrd"
SERVER_NAME="my-server"
SERVER_TYPE="cx21" 
IMAGE="ubuntu-20.04"
PASSWORD="Afzal@3604"

sudo apt-get update
sudo apt-get install jq


# Create a new server
echo "Creating Hetzner server..."
response=$(curl -X POST -H "Content-Type: application/json" \
     -H "Authorization: Bearer $API_TOKEN" \
     -d '{"name":"'"$SERVER_NAME"'","server_type":"'"$SERVER_TYPE"'","image":"'"$IMAGE"'","start_after_create":true}' \
     "https://api.hetzner.cloud/v1/servers")

# Extract server ID from the response   
SERVER_ID=$(echo "$response" | jq -r '.server.id')

# Wait for server creation to complete
echo "Waiting for server to be created..."
while true; do
    status=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
        "https://api.hetzner.cloud/v1/servers/$SERVER_ID" | jq -r '.server.status')
    if [ "$status" = "running" ]; then
        break
    fi
    sleep 5
done

# Set the root password
echo "Setting root password..."
curl -X POST -H "Content-Type: application/json" \
     -H "Authorization: Bearer $API_TOKEN" \
     -d '{"root_password":"'"$PASSWORD"'"}' \
     "https://api.hetzner.cloud/v1/servers/$SERVER_ID/actions/reset_password"

# Print server information
echo "Server created successfully!"
echo "Server ID: $SERVER_ID"
echo "Server Name: $SERVER_NAME"
echo "Server IP Address: $(curl -s -H "Authorization: Bearer $API_TOKEN" "https://api.hetzner.cloud/v1/servers/$SERVER_ID" | jq -r '.server.public_net.ipv4.ip')"

echo "done"