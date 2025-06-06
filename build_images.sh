#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
CUSTOMER_SERVICE_DIR="customer-service"
CUSTOMER_IMAGE_NAME="customer-service"
CUSTOMER_IMAGE_TAG="latest"

ORDER_SERVICE_DIR="order-service"
ORDER_IMAGE_NAME="order-service"
ORDER_IMAGE_TAG="latest"
# ---------------------

echo "Building Docker image for Customer Service: ${CUSTOMER_IMAGE_NAME}:${CUSTOMER_IMAGE_TAG}"
# Navigate to the customer service directory
pushd "$CUSTOMER_SERVICE_DIR" > /dev/null

# Build the Docker image using the base name
docker build -t "${CUSTOMER_IMAGE_NAME}:${CUSTOMER_IMAGE_TAG}" .

echo "Customer Service image built: ${CUSTOMER_IMAGE_NAME}:${CUSTOMER_IMAGE_TAG}"

# Navigate back
popd > /dev/null

echo ""
echo "Building Docker image for Order Service: ${ORDER_IMAGE_NAME}:${ORDER_IMAGE_TAG}"
# Navigate to the order service directory
pushd "$ORDER_SERVICE_DIR" > /dev/null

# Build the Docker image using the base name
docker build -t "${ORDER_IMAGE_NAME}:${ORDER_IMAGE_TAG}" .

echo "Order Service image built: ${ORDER_IMAGE_NAME}:${ORDER_IMAGE_TAG}"

# Navigate back
popd > /dev/null

echo ""
echo "Docker images built successfully!" 