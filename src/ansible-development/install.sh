#! /usr/bin/env bash
set -ex


if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
  echo "Running apt-get update..."
  apt-get update -y
fi

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends wget ca-certificates vim colordiff

if ! type git > /dev/null 2>&1; then
  apt-get install -y --no-install-recommends git
fi

apt-get install -y --no-install-recommends python3-pip python3-virtualenv

ANSIBLE_VERSION="${VERSION:-latest}";

if [[ "${ANSIBLE_VERSION}" == "latest" ]]; then
  ANSIBLE_VERSION=$(wget -nv -O - "https://pypi.org/project/ansible/" \
    | grep  -e '<div class="package-header__left">' -A 2 \
    | grep "ansible" | sed "s/ *ansible //")
fi

virtualenv /opt/ansible --system-site-packages

source /opt/ansible/bin/activate

pip install ansible==${ANSIBLE_VERSION} \
            ansible-lint \
            docker \
            molecule \
            toml \
            httpx \
            passlib

cat >> /opt/ansible/postCreateCommand.sh << EOF
#! /usr/bin/env bash

ANSIBLE_CONFIG="\$PWD/ansible.cfg"

echo "export ANSIBLE_CONFIG=\"\$ANSIBLE_CONFIG\"" >> ~/.profile

echo "Checking '\$PWD' for requirements..."
if [ -f 'requirements.yml' ]; then
  ansible-galaxy collection install -r requirements.yml
  ansible-galaxy install -r requirements.yml
fi
EOF

chmod 0755 /opt/ansible/postCreateCommand.sh

rm -rf /var/lib/apt/lists/*

if ! type docker > /dev/null 2>&1; then
    echo -e '\n(*) Warning: The docker command was not found.\n\nYou can use one of the following scripts to install it:\n\nhttps://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker-in-docker.md\n\nor\n\nhttps://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker.md'
fi

echo 'The 'ansible-development' install script has completed!'
