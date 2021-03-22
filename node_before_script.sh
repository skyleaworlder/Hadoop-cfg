#!/bin/bash
# This is a script used before hadoop configuration.
# - step: 0
#   target: create etc backup folder
# - step: 1
#   target: some cfg about host & make publickey ssh possible
#   info:
#       - change hostname
#       - change /etc/hosts
#       - ssh-keygen
#       - distribute public key by ssh-copy-id
# - step: 2
#   target: download java & hadoop
#   info:
#       - change /etc/apt/sources.list
#       - use 163 src
#       - install java

# 0. create a folder to make a backup for some "etc" files:
#   ~/.hadoop.bak.d/:
#       - .bashrc: ~/.bashrc
#       - hosts: /etc/hosts
#       - sources.list: /etc/apt/sources.list
BAK_PATH=~/.hadoop.bak.d
mkdir $BAK_PATH
sudo cp /etc/hosts $BAK_PATH
sudo cp /etc/apt/sources.list $BAK_PATH
sudo cp ~/.bashrc $BAK_PATH

# 1. Change hostname of ECS
# e.g. if IP of your UCloud-ECS is 10.23.169.137, your hostname will be initialized as 10-23-159-192
# you can execute "hostname" on your ECS to get the hostname.
# your cluster has 3 nodes normally in this lab.
# For master node, "master" can be set as hostname here.
# For slave node, "slave1" and "slave2" are recommended.
read -p "[$USER]: Your hostname will be replaced by (e.g. master or slave1): " host
sudo hostnamectl set-hostname $host

# 2. ssh-keygen
echo "[$USER]: Begin to do with ssh configuration."
echo "[$USER]: (default file path and empty passphrase is used)"
# default type is RSA, passphrase is null, while file output-path is default
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa

# 3. Change /etc/hosts && ssh-copy-id
echo "[$USER]: Begin to 'copy' your id_rsa.pub(public key used in ssh) to other machines."
read -p "[$USER]: Please input master's LAN-IP (e.g. 10.0.0.1): " masterIP
echo "$masterIP master" > .tmp.ipcfg
# distribute ssh public key to master node
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$masterIP

i=1
read -p "[$USER]: Please input the number of slaves (e.g. 2): " slaveNum
while [ $i -le $slaveNum ]
do
    read -p "[$USER]: Please input the LAN-IP of a slave (e.g. 10.0.0.1): " slaveIP
    read -p "[$USER]: Please input the serial number of the slave above (e.g. 1): " slaveNo
    echo "$slaveIP  slave$slaveNo" >> .tmp.ipcfg

    # distribute it to slave node
    ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$slaveIP
    ((i=i+1))
done
sudo bash -c "cat .tmp.ipcfg >> /etc/hosts"

# 4. Change /etc/apt/sources.list
# focal --> Ubuntu 20.04
# proposed and src are "commented".
(
cat <<EOF
deb http://mirrors.163.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ focal-backports main restricted universe multiverse
# deb http://mirrors.163.com/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src http://mirrors.163.com/ubuntu/ focal main restricted universe multiverse
# deb-src http://mirrors.163.com/ubuntu/ focal-security main restricted universe multiverse
# deb-src http://mirrors.163.com/ubuntu/ focal-updates main restricted universe multiverse
# deb-src http://mirrors.163.com/ubuntu/ focal-backports main restricted universe multiverse
# deb-src http://mirrors.163.com/ubuntu/ focal-proposed main restricted universe multiverse
EOF
) > .tmp.srccfg
sudo bash -c "cat .tmp.srccfg > /etc/apt/sources.list"
sudo apt-get update
sudo apt-get upgrade

# 5. install jdk
# Normally, "java -version" print:
#   openjdk version "1.8.0_282"
#   OpenJDK Runtime Environment (balabala)
#   OpenJDK 64-Bit Server VM (balabala)
sudo apt install openjdk-8-jdk-headless
if [ $(java -version 2>&1 | grep -c "openjdk version") -ge 1 ];then
    echo "[$USER]: jdk install successfully."
else
    echo "[$USER]: fail to install jdk. script exits."
    exit 1
fi
