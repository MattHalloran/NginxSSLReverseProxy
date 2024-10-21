#!/bin/bash
# Fully sets up server

set -e          # Exit if any command fails
set -o pipefail # Exit if piped command (e.g. curl, apt-get) fails

HERE=$(dirname $0)
source "${HERE}/utils.sh"

local_dev=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --local) local_dev=true ;;
    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
    shift
done

check_root_privileges() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo privileges"
        exit 1
    fi
}

handle_apt_errors() {
    # Function to handle errors during apt operations
    if ! "$@"; then
        error "ERROR: APT operation failed: $*"
        warning "APT failures may affect the installation of necessary components. Check output above."
    fi
}

setup_ubuntu() {
    header "Cleaning up apt library"
    sudo rm -rvf /var/lib/apt/lists/*

    header "Upgrading cache limit"
    sed -i 's/^.*APT::Cache-Limit.*$/APT::Cache-Limit \"100000000\";/' /etc/apt/apt.conf.d/70debconf

    header "Checking for package updates"
    handle_apt_errors sudo apt-get update

    header "Running upgrade"
    handle_apt_errors sudo apt-get -y upgrade

    info "Updating max listeners, since npm uses a lot. Not sure exactly what they do, but the default max amount is not enough"
    echo fs.inotify.max_user_watches=20000 | sudo tee -a /etc/sysctl.conf
    echo vm.overcommit_memory=1 | sudo tee -a /etc/sysctl.conf
}

setup_docker() {
    header "Installing Docker prerequisites"
    if ! command -v docker > /dev/null 2>&1; then
        sudo apt-get remove -y docker docker-engine docker.io containerd runc
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

        header "Adding Docker’s official GPG key"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    fi

    header "Verifying Docker Engine"
    sudo docker run hello-world || true  # Non-blocking

    if ! getent group docker > /dev/null; then
        sudo groupadd docker
        sudo usermod -aG docker $USER
    fi

    header "Configuring Docker to start on boot"
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    if ! command -v docker-compose > /dev/null; then
        header "Installing Docker Compose"
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    if ! sudo docker network ls --filter name=^nginx-proxy$ --format "{{.Name}}" | grep -qw nginx-proxy; then
        header "Creating proxy network"
        sudo docker network create nginx-proxy
    fi
}

setup_self_cert() {
    if ! command -v mkcert > /dev/null; then
        header "Installing mkcert for local SSL development certificates"
        sudo apt-get install -y libnss3-tools
        curl -L "https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64" -o mkcert
        chmod +x mkcert
        sudo mv mkcert /usr/local/bin/
        mkcert -install
    fi

    header "Generating SSL certificates for localhost"
    if [ ! -f "localhost+2.pem" ]; then
        mkcert localhost 127.0.0.1 ::1
        info "Certificates generated at: $(pwd)"
    else
        info "Existing SSL certificates found. Skipping regeneration."
    fi
}

purge_nginx() {
    header "Checking for Nginx on host machine"
    info "Nginx will be inside a docker instance, rather than installed on the host machine. We will need to purge any existing Nginx configurations on the host machine."

    # Check if nginx is installed
    if dpkg -l | grep -qw nginx; then
        # Nginx is installed, ask for confirmation to purge
        if prompt_confirm "Nginx configurations found. Do you want to purge them?"; then
            header "Purging existing Nginx configurations"
            sudo apt-get purge -y nginx nginx-common
        else
            info "Purging canceled by user."
        fi
    else
        info "No existing Nginx configurations found. No action required."
    fi
}

setup_firewall() {
    info "Since Nginx is inside docker, we must handle the firewall settings ourselves"
    header "Setting up firewall"
    # Enable firewall
    sudo ufw enable
    # Disable all connections
    sudo ufw default allow outgoing
    sudo ufw default deny incoming
    # Only allow 80 and 443 (80 is required for certificates)
    sudo ufw allow 80/tcp
    sudo ufw allow ssh
    sudo sysctl -p
}

main() {
    check_root_privileges
    setup_ubuntu
    setup_docker
    if [ "$local_dev" = true ]; then
        setup_self_cert
    fi
    purge_nginx
    setup_firewall
}

run_if_executed main "$@"
