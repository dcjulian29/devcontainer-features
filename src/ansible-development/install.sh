#! /usr/bin/env bash
set -ex

apt-get update -y

export DEBIAN_FRONTEND=noninteractive

apt-get -y install --no-install-recommends wget ca-certificates vim colordiff
apt-get -y install --no-install-recommends python3-pip python3-virtualenv

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
            passlib

cat >> /opt/ansible/postCreateCommand.sh << EOF
#! /usr/bin/env bash

source /opt/ansible/bin/activate

cd \${containerWorkspaceFolder}

if [ -f requirements.yml ]; then
  ansible-galaxy collection install -r requirements.yml
  ansible-galaxy install -r requirements.yml
fi
EOF

chmod 0755 /opt/ansible/postCreateCommand.sh

rm -rf /var/lib/apt/lists/*
