#!/bin/bash
set -ex

source dev-container-features-test-lib

check "version" ansible --version
check "version" ansible-community --version
check "version" ansible-config --version
check "version" ansible-connection --version
check "version" ansible-console --version
check "version" ansible-doc --version
check "version" ansible-galaxy --version
check "version" ansible-inventory --version
check "version" ansible-lint --version
check "version" ansible-playbook --version
check "version" ansible-pull --version
check "version" ansible-test --version
check "version" ansible-vault --version
check "version" yamllint --version


check "version" molecule --version

reportResults
