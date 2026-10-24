#!/bin/bash

# Simple deployment script for NixOS configuration

set -e

HOST=${1:-"Zeus"}
ACTION=${2:-"switch"}

echo "Deploying configuration for $HOST using nixos-rebuild $ACTION..."

sudo nixos-rebuild --flake .#$HOST $ACTION

echo "Deployment completed successfully!"