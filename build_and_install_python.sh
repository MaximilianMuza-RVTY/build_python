#!/bin/bash
# Complete Python 3 Build and Installation Script
# This script builds Python, creates a local apt repository, and installs Python
# Copyright (c) JetsonHacks 2023

# Default version
version="3.11"

help_message="Usage: $0 [-v|--version version_number] [-h|--help]
Options:
  -v, --version  Provide a version number (3.9, 3.10, or 3.11).
  -h, --help     Show this help message."

# Parse command-line options
OPTIONS=$(getopt -o v:h --longoptions version:,help -- "$@")
eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -v|--version)
            version="$2"
            shift 2
            ;;
        -h|--help)
            echo "$help_message"
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Incorrect options provided"
            echo "$help_message"
            exit 1
            ;;
    esac
done

# Validate the provided version number
if [[ "$version" != "3.9" ]] && [[ "$version" != "3.10" ]] && [[ "$version" != "3.11" ]]; then
    echo "The version number $version is not supported. Please provide a correct version (3.9, 3.10, or 3.11)."
    exit 1
fi

echo "======================================="
echo "Complete Python $version Build Process"
echo "======================================="

# Get the script directory to ensure we can find the other scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "Step 1: Building Python $version..."
echo "-----------------------------------"

# Execute build_python3.sh with the specified version
if [ -f "$SCRIPT_DIR/build_python3.sh" ]; then
    bash "$SCRIPT_DIR/build_python3.sh" --version "$version"
    if [ $? -ne 0 ]; then
        echo "Error: Python build failed. Exiting."
        exit 1
    fi
    echo "Python $version build completed successfully."
else
    echo "Error: build_python3.sh not found in $SCRIPT_DIR"
    exit 1
fi

echo ""
echo "Step 2: Creating local apt repository..."
echo "---------------------------------------"

# Execute make_apt_repository.sh with the specified version
if [ -f "$SCRIPT_DIR/make_apt_repository.sh" ]; then
    bash "$SCRIPT_DIR/make_apt_repository.sh" --version "$version"
    if [ $? -ne 0 ]; then
        echo "Error: Repository creation failed. Exiting."
        exit 1
    fi
    echo "Local apt repository created successfully."
else
    echo "Error: make_apt_repository.sh not found in $SCRIPT_DIR"
    exit 1
fi

echo ""
echo "Step 3: Installing Python $version-full..."
echo "------------------------------------------"

# Install the full Python package
sudo apt install -y python$version-full
if [ $? -ne 0 ]; then
    echo "Error: Python $version-full installation failed."
    exit 1
fi

echo ""
echo "======================================="
echo "Installation completed successfully!"
echo "======================================="
echo "Python $version has been built, packaged, and installed."
echo ""
echo "You can now use Python $version with the command: python$version"
echo "To check the installation, run: python$version --version"
