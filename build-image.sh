#!/usr/bin/env bash

# Build the overlay WAR
mvn package

# Build the Docker image
docker build -t lockss/laaws-openwayback .