#!/bin/bash

# Docker Deployment Automation Script with Custom Ports, Versioning, and Dockerfile Path
# Automates Docker build, tag (with incremental versioning), push, and run.

IMAGE_NAME="pingpong-counter"           # Set your image name here
REGISTRY=""     # Replace with your Docker registry or leave empty for local
VERSION_FILE=".version"       # Version file to track builds
DOCKERFILE_PATH="./ping-pong/Dockerfile"  # Path to the Dockerfile
BUILD_CONTEXT="./ping-pong/"                # Path to the app files
HOST_PORT=3005                  # Host port
CONTAINER_PORT=3000             # Container port

# Generate unique tag
if [ -f "$VERSION_FILE" ]; then
    # Read the current version number from the version file
    VERSION=$(<"$VERSION_FILE")

    # Extract major and minor versions
    MAJOR=$(echo "$VERSION" | cut -d. -f1 | cut -c2-)  # Get major version
    MINOR=$(echo "$VERSION" | cut -d. -f2)              # Get minor version

    # Increment the minor version by 1
    MINOR=$((MINOR + 1))

    # Combine them back to the version format vX.Y
    NEW_VERSION="v$MAJOR.$MINOR"
else
    # Initial version if version file doesn't exist
    NEW_VERSION="v1.0"
fi

echo "$NEW_VERSION" > "$VERSION_FILE"  # Save new version to the file
IMAGE_TAG="$NEW_VERSION"

echo "Building Docker image $IMAGE_NAME:$IMAGE_TAG using Dockerfile at $DOCKERFILE_PATH..."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" -f "$DOCKERFILE_PATH" "$BUILD_CONTEXT"

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Docker build failed. Exiting."
    exit 1
fi

# Tag and push to registry if provided
if [ -n "$REGISTRY" ]; then
    echo "Tagging image for registry $REGISTRY..."
    docker tag "$IMAGE_NAME:$IMAGE_TAG" "$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

    echo "Pushing image to registry..."
    docker push "$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

    if [ $? -ne 0 ]; then
        echo "Failed to push image. Exiting."
        exit 1
    fi
fi

# Run container with customizable ports
echo "Running container from image $IMAGE_NAME:$IMAGE_TAG on port $HOST_PORT -> $CONTAINER_PORT..."
docker run -d --name "$IMAGE_NAME"_container -p "$HOST_PORT":"$CONTAINER_PORT" "$IMAGE_NAME:$IMAGE_TAG"

# Check if the container started successfully
if [ $? -eq 0 ]; then
    echo "Container started successfully with version $IMAGE_TAG on port $HOST_PORT."
else
    echo "Failed to start container."
    exit 1
fi
