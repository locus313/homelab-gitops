#!/bin/bash

# ============================================================================
# Install additional development tools for the code-server container.
# Runs as a custom container init script on first start.
# ============================================================================

set -euo pipefail

echo "**** Installing additional development tools ****"

# Install 1Password CLI
if ! command -v op &> /dev/null; then
    echo "**** Installing 1Password CLI ****"
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list
    apt-get update
    apt-get -y install 1password-cli
fi

# Install Packer
if ! command -v packer &> /dev/null; then
    echo "**** Installing Packer ****"
    curl -sS https://apt.releases.hashicorp.com/gpg | gpg --dearmor --output /etc/apt/keyrings/packer-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packer-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/packer.list
    apt-get update
    apt-get -y install packer
fi

# Install AWS Session Manager Plugin
if ! command -v session-manager-plugin &> /dev/null; then
    echo "**** Installing AWS Session Manager Plugin ****"
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
    dpkg -i /tmp/session-manager-plugin.deb
    rm -f /tmp/session-manager-plugin.deb
fi

# Install aws-vault
if ! command -v aws-vault &> /dev/null; then
    echo "**** Installing aws-vault ****"
    curl -L -o /usr/local/bin/aws-vault https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64
    chmod 755 /usr/local/bin/aws-vault
fi

# Install tfenv (Terraform version manager)
if [ ! -d "/config/.tfenv" ]; then
    echo "**** Installing tfenv ****"
    git clone --depth=1 https://github.com/tfutils/tfenv.git /config/.tfenv
    # Install specific Terraform versions
    /config/.tfenv/bin/tfenv install 0.12.31
    /config/.tfenv/bin/tfenv install 0.14.3
    /config/.tfenv/bin/tfenv install 0.14.11
    /config/.tfenv/bin/tfenv install 1.1.9
    /config/.tfenv/bin/tfenv install 1.2.2
    /config/.tfenv/bin/tfenv install 1.3.9
    /config/.tfenv/bin/tfenv install 1.4.2
    /config/.tfenv/bin/tfenv use 0.12.31
fi

# Configure Docker group for abc user
if [ -S /var/run/docker.sock ]; then
    echo "**** Configuring Docker access ****"
    DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock)

    # Look up existing group by GID, or create docker group if none exists
    DOCKER_GROUP=$(getent group "${DOCKER_SOCK_GID}" | cut -d: -f1)
    if [ -z "${DOCKER_GROUP}" ]; then
        groupadd -g "${DOCKER_SOCK_GID}" docker
        DOCKER_GROUP=docker
    fi

    usermod -aG "${DOCKER_GROUP}" abc

    # Set ACL for docker socket
    setfacl --modify user:abc:rw /var/run/docker.sock 2>/dev/null || true
fi

# Install Homebrew as abc user (brew refuses to install as root)
# Pre-create the prefix and cache directories as root then hand ownership to abc
if [ ! -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    echo "**** Installing Homebrew ****"
    mkdir -p /home/linuxbrew/.linuxbrew
    chown -R abc:abc /home/linuxbrew
    mkdir -p /config/.cache/Homebrew
    chown -R abc:abc /config/.cache/Homebrew
    runuser -u abc -- bash -c 'NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash' || true
fi

# Install Homebrew packages as abc user
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    echo "**** Installing Homebrew packages ****"

    # Install lacework-cli
    if [ ! -x "/home/linuxbrew/.linuxbrew/bin/lacework" ]; then
        echo "**** Installing lacework-cli ****"
        runuser -u abc -- /home/linuxbrew/.linuxbrew/bin/brew install lacework/tap/lacework-cli
    fi

    # Install k9s
    if [ ! -x "/home/linuxbrew/.linuxbrew/bin/k9s" ]; then
        echo "**** Installing k9s ****"
        runuser -u abc -- /home/linuxbrew/.linuxbrew/bin/brew install derailed/k9s/k9s
    fi
else
    echo "**** WARNING: Homebrew installation failed, skipping brew-based packages ****"
fi

echo "**** Additional tools installation complete ****"
