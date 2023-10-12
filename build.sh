#!/bin/bash

readonly PORT=80
readonly NETWORK_NAME="simple-auth-app"
readonly CONTAINER_NAME="nginx"
readonly IMAGE_NAME="nginx:latest"

check_and_create_network() {
    network_exists=$(docker network ls | grep "$NETWORK_NAME")

    if [ -z "$network_exists" ]; then
        docker network create "$NETWORK_NAME"
        echo "Docker network $NETWORK_NAME created."
    else
        echo "Docker network $NETWORK_NAME already exists."
    fi
}

check_and_remove_container() {
  local container_name="$1"

    container_exists=$(docker ps -a --filter "name=^${container_name}$" --format '{{.Names}}')

    if [ -n "$container_exists" ]; then
        docker rm -f "${container_name}"
        echo "Docker container '${container_name}' removed."
    else
        echo "Docker container '${container_name}' does not exist."
    fi
}

check_and_create_network
rm -r dist
parcel build index.html
check_and_remove_container "$CONTAINER_NAME"
docker run --name "$CONTAINER_NAME" -v /$(pwd)/dist:/data/www:ro -v /$(pwd)/default.conf:/etc/nginx/conf.d/default.conf:ro -d -p "$PORT":"$PORT" --network="$NETWORK_NAME" "$IMAGE_NAME"
#docker run --name "$CONTAINER_NAME" -v /$(pwd)/dist:/data/www:ro -v /$(pwd)/default.conf:/etc/nginx/conf.d/default.conf:ro -v /$(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro -d -p "$PORT":"$PORT" --network="$NETWORK_NAME" "$IMAGE_NAME"