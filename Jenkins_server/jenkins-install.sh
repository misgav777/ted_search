#!/bin/bash

# Install Jenkins
apt-get update
apt-get upgrade -y
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install fontconfig -y
apt-get install openjdk-17-jre -y
apt-get install jenkins -y
systemctl enable jenkins
systemctl start jenkins

# Install git
apt-get install git -y

# Install Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get install terraform -y