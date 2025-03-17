#!/bin/bash

# Test script for Mac Server API endpoints
API_KEY="test-api-key"
BASE_URL="http://localhost:8080"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Mac Server API Test Script${NC}"
echo "================================"

# Test health endpoint
echo -e "\n${YELLOW}Testing health endpoint...${NC}"
health_response=$(curl -s $BASE_URL/health)
if [ "$health_response" == "OK" ]; then
    echo -e "${GREEN}Health check passed: $health_response${NC}"
else
    echo -e "${RED}Health check failed: $health_response${NC}"
fi

# Test version endpoint
echo -e "\n${YELLOW}Testing version endpoint...${NC}"
version_response=$(curl -s $BASE_URL/version)
echo "Version response: $version_response"

# Test camera list endpoint
echo -e "\n${YELLOW}Testing camera list endpoint...${NC}"
camera_response=$(curl -s -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/cameras)
echo "Camera list response: $camera_response"

# Test snapshot endpoint
echo -e "\n${YELLOW}Testing snapshot endpoint...${NC}"
snapshot_response=$(curl -s -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/cameras/snapshot -o snapshot.jpg -w "%{http_code}")
if [ "$snapshot_response" == "200" ]; then
    echo -e "${GREEN}Snapshot saved to snapshot.jpg${NC}"
else
    echo -e "${RED}Failed to get snapshot: HTTP $snapshot_response${NC}"
fi

# Test stream endpoints
echo -e "\n${YELLOW}Testing stream creation...${NC}"
stream_response=$(curl -s -X POST -H "X-API-Key: $API_KEY" -H "Content-Type: application/json" \
    -d '{"quality":"medium","frameRate":15}' \
    $BASE_URL/api/v1/streams)
echo "Stream creation response: $stream_response"

# Extract stream ID if available
stream_id=$(echo $stream_response | grep -o '"streamId":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$stream_id" ]; then
    echo -e "${GREEN}Stream created with ID: $stream_id${NC}"
    
    # Test getting a frame
    echo -e "\n${YELLOW}Testing frame retrieval...${NC}"
    frame_response=$(curl -s -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/streams/$stream_id/frame -o frame.jpg -w "%{http_code}")
    if [ "$frame_response" == "200" ]; then
        echo -e "${GREEN}Frame saved to frame.jpg${NC}"
    else
        echo -e "${RED}Failed to get frame: HTTP $frame_response${NC}"
    fi
    
    # Test stopping the stream
    echo -e "\n${YELLOW}Testing stream stop...${NC}"
    stop_response=$(curl -s -X DELETE -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/streams/$stream_id)
    echo "Stream stop response: $stop_response"
else
    echo -e "${RED}Failed to extract stream ID${NC}"
fi

# Test SSH server status
echo -e "\n${YELLOW}Testing SSH server status...${NC}"
ssh_response=$(curl -s -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/ssh/status)
echo "SSH server status: $ssh_response"

# Test adding an SSH key
echo -e "\n${YELLOW}Testing adding SSH key...${NC}"
# Generate a test key (base64 encoded)
test_key=$(echo "ssh-rsa TESTKEY user@example.com" | base64)
key_response=$(curl -s -X POST -H "X-API-Key: $API_KEY" -H "Content-Type: application/json" \
    -d "{\"key\":\"$test_key\",\"comment\":\"Test Key\"}" \
    $BASE_URL/api/v1/ssh/keys)
echo "Add key response: $key_response"

# Extract key ID if available
key_id=$(echo $key_response | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$key_id" ]; then
    echo -e "${GREEN}Key added with ID: $key_id${NC}"
    
    # Test listing keys
    echo -e "\n${YELLOW}Testing listing SSH keys...${NC}"
    keys_response=$(curl -s -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/ssh/keys)
    echo "Keys list: $keys_response"
    
    # Test removing the key
    echo -e "\n${YELLOW}Testing removing SSH key...${NC}"
    remove_response=$(curl -s -X DELETE -H "X-API-Key: $API_KEY" $BASE_URL/api/v1/ssh/keys/$key_id)
    echo "Remove key response: $remove_response"
else
    echo -e "${RED}Failed to extract key ID${NC}"
fi

echo -e "\n${GREEN}Tests completed!${NC}" 