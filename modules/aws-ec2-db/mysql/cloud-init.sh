#! /bin/bash
sudo apt-get update
sudo apt-get -qq install mysql-server > /dev/null
sudo systemctl start mysql
sudo systemctl enable mysql
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent