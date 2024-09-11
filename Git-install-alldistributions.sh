#!/bin/bash

# Function to install Git on Debian-based systems
install_debian() {
    echo "Detected Debian-based system. Installing Git..."
    sudo apt update
    sudo apt install -y git
}

# Function to install Git on Red Hat-based systems
install_redhat() {
    echo "Detected Red Hat-based system. Installing Git..."
    sudo dnf install -y git   # For Fedora and newer Red Hat systems
    # sudo yum install -y git # Uncomment this line for older Red Hat/CentOS systems
}

# Function to install Git on macOS
install_macos() {
    echo "Detected macOS. Installing Git..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install git
}

# Function to detect the OS and call the appropriate install function
install_git() {
    if [[ -f /etc/debian_version ]]; then
        install_debian
    elif [[ -f /etc/redhat-release ]]; then
        install_redhat
    elif [[ "$(uname)" == "Darwin" ]]; then
        install_macos
    else
        echo "Unsupported operating system. Please install Git manually."
        exit 1
    fi
}

# Main script execution
install_git
