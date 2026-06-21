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
# The HashiCorp repo may already be configured by the code-server-terraform mod;
# skip adding it again to avoid conflicting Signed-By values.
if ! command -v packer &> /dev/null; then
    echo "**** Installing Packer ****"
    if ! grep -r "apt.releases.hashicorp.com" /etc/apt/sources.list.d/ &> /dev/null; then
        curl -sS https://apt.releases.hashicorp.com/gpg | gpg --dearmor --output /usr/share/keyrings/hashicorp.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
        apt-get update
    fi
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
# Resolves the latest release via the GitHub API, downloads the binary and the
# project-published checksums.txt, verifies they match, then installs.
# This ensures we always run the latest version without a hardcoded SHA that
# requires manual updates on each release.
if ! command -v aws-vault &> /dev/null; then
    echo "**** Installing aws-vault ****"
    _aws_vault_version="$(curl -fsSL \
        https://api.github.com/repos/99designs/aws-vault/releases/latest \
        | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"

    if [ -z "${_aws_vault_version}" ]; then
        echo "**** WARNING: Could not determine latest aws-vault version, skipping ****" >&2
    else
        echo "**** Installing aws-vault ${_aws_vault_version} ****"
        _aws_vault_tmp="$(mktemp)"
        _aws_vault_checksums="$(mktemp)"
        _base_url="https://github.com/99designs/aws-vault/releases/download/${_aws_vault_version}"

        curl -fsSL "${_base_url}/aws-vault-linux-amd64"  -o "${_aws_vault_tmp}"
        curl -fsSL "${_base_url}/checksums.txt"           -o "${_aws_vault_checksums}"

        # Verify the binary against the published checksum
        _expected="$(grep 'aws-vault-linux-amd64$' "${_aws_vault_checksums}" | awk '{print $1}')"
        _actual="$(sha256sum "${_aws_vault_tmp}" | awk '{print $1}')"
        if [ "${_expected}" != "${_actual}" ]; then
            echo "**** ERROR: aws-vault checksum mismatch — aborting install ****" >&2
            echo "  expected: ${_expected}" >&2
            echo "  actual:   ${_actual}" >&2
            rm -f "${_aws_vault_tmp}" "${_aws_vault_checksums}"
        else
            install -m 755 "${_aws_vault_tmp}" /usr/local/bin/aws-vault
            echo "**** aws-vault ${_aws_vault_version} installed and verified ****"
            rm -f "${_aws_vault_tmp}" "${_aws_vault_checksums}"
        fi
    fi
fi

# Install tfenv (Terraform version manager)
if [ ! -d "/config/.tfenv" ]; then
    echo "**** Installing tfenv ****"
    git clone --depth=1 --branch v3.2.2 https://github.com/tfutils/tfenv.git /config/.tfenv
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

    # Download to a temp file rather than piping directly to bash.
    # HTTPS + the high-profile Homebrew/install repo provide sufficient integrity
    # for a homelab first-install without pinning a specific SHA.
    _brew_installer="$(mktemp)"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
        -o "${_brew_installer}"
    runuser -u abc -- bash -c "NONINTERACTIVE=1 bash '${_brew_installer}'" || true
    rm -f "${_brew_installer}"
fi

# Install Homebrew packages as abc user
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    # Update Homebrew and upgrade all installed packages on every container start.
    # Since /home/linuxbrew is a persistent volume, this keeps packages current
    # whenever the container image is updated or recreated.
    echo "**** Updating Homebrew and upgrading packages ****"
    runuser -u abc -- /home/linuxbrew/.linuxbrew/bin/brew update --quiet || true
    runuser -u abc -- /home/linuxbrew/.linuxbrew/bin/brew upgrade --quiet || true

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
