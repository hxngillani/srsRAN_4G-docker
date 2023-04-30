#!/bin/bash
# Build the Docker images
docker-compose build

# Start the Docker containers in the background
docker-compose up -d
