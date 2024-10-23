#!/bin/bash
# Fully sets up server

set -e          # Exit if any command fails
set -o pipefail # Exit if piped command (e.g. curl, apt-get) fails

HERE=$(dirname $0)
source "${HERE}/utils.sh"

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
    # Remove any duplicates of fs.inotify.max_user_watches and vm.overcommit_memory
    sudo sed -i '/^fs.inotify.max_user_watches=.*$/d' /etc/sysctl.conf
    sudo sed -i '/^vm.overcommit_memory=.*$/d' /etc/sysctl.conf
    # Add fs.inotify.max_user_watches if not present
    if ! grep -q "^fs.inotify.max_user_watches=30000$" /etc/sysctl.conf; then
        echo "fs.inotify.max_user_watches=30000" | sudo tee -a /etc/sysctl.conf
    else
        info "fs.inotify.max_user_watches is already set"
    fi
    # Add vm.overcommit_memory if not present
    if ! grep -q "^vm.overcommit_memory=1$" /etc/sysctl.conf; then
        echo "vm.overcommit_memory=1" | sudo tee -a /etc/sysctl.conf
    else
        info "vm.overcommit_memory is already set"
    fi
}

setup_docker() {
    header "Installing Docker prerequisites"
    if ! command -v docker >/dev/null 2>&1; then
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

        header "Adding Docker’s official GPG key"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    else
        info "Detected Docker version: $(docker --version)"
    fi

    header "Verifying Docker Engine"
    sudo docker run hello-world || true # Non-blocking
    # Remove the "hello-world" container to avoid clutter
    if sudo docker ps -a --filter "ancestor=hello-world" --format "{{.ID}}" | grep -q .; then
        sudo docker rm $(sudo docker ps -a --filter "ancestor=hello-world" --format "{{.ID}}")
    fi

    if ! getent group docker >/dev/null; then
        sudo groupadd docker
        sudo usermod -aG docker $USER
    fi

    header "Configuring Docker to start on boot"
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    if ! command -v docker-compose >/dev/null; then
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
    if ! command -v mkcert >/dev/null; then
        header "Installing mkcert for local SSL development certificates"
        sudo apt-get install -y libnss3-tools
        curl -L "https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64" -o mkcert
        chmod +x mkcert
        sudo mv mkcert /usr/local/bin/
        mkcert -install
    fi

    header "Generating SSL certificates for localhost"
    local CERT_DIR="${HERE}/../certs"
    mkdir -p "${CERT_DIR}"
    if [ ! -f "${CERT_DIR}/localhost+2.pem" ]; then
        cd "${CERT_DIR}"
        mkcert localhost 127.0.0.1 ::1
        info "Certificates generated at: ${CERT_DIR}"
        cd -
    else
        info "Existing SSL certificates found. Skipping regeneration."
    fi

    # Ensure the certificates are readable
    chmod 644 "${CERT_DIR}/localhost+2.pem"
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

SERVER_LOCATION="local" # Default to local
main() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -l | --location)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: Option $key requires an argument."
                exit 1
            fi
            SERVER_LOCATION="${2}"
            shift # past argument
            shift # past value
            ;;
        -h | --help)
            echo "Usage: $0 [-l SERVER_LOCATION] [-h]"
            echo "  -l --location: Server location (e.g. \"local\", \"remote\")"
            echo "  -h --help: Show this help message"
            exit 0
            ;;
        esac
    done

    check_root_privileges
    setup_ubuntu
    setup_docker
    if [ "$SERVER_LOCATION" == "local" ]; then
        setup_self_cert
    fi
    purge_nginx
    setup_firewall
}

run_if_executed main "$@"
