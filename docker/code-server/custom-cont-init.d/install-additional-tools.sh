#!/bin/bash

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
    # Get the GID of docker socket
    DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
    
    # Create docker group with matching GID if it doesn't exist
    if ! getent group docker > /dev/null; then
        groupadd -g ${DOCKER_SOCK_GID} docker
    fi
    
    # Add abc user to docker group
    usermod -aG docker abc
    
    # Set ACL for docker socket
    setfacl --modify user:abc:rw /var/run/docker.sock 2>/dev/null || true
fi

# Install Homebrew packages if brew is available
if command -v brew &> /dev/null; then
    echo "**** Installing Homebrew packages ****"
    
    # Install lacework-cli
    if ! command -v lacework &> /dev/null; then
        echo "**** Installing lacework-cli ****"
        brew install lacework/tap/lacework-cli
    fi
    
    # Install k9s
    if ! command -v k9s &> /dev/null; then
        echo "**** Installing k9s ****"
        brew install derailed/k9s/k9s
    fi
else
    echo "**** Homebrew not available, skipping brew-based packages ****"
fi

echo "**** Additional tools installation complete ****"
