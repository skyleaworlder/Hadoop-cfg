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
#       - install java & hadoop
#       - check integrity

# 0. create a folder to make a backup for some "etc" files
BAK_PATH=~/hadoop_bak
mkdir $BAK_PATH
sudo cp /etc/hosts $BAK_PATH
sudo cp /etc/apt/sources.list $BAK_PATH
sudo cp ~/.bashrc $BAK_PATH

# 1. Change hostname of ECS
# e.g. if IP of your UCloud-ECS is 10.23.169.137, your hostname will be 10-23-159-192
# you can execute "hostname" over SSH to get the hostname of your ECS
# For master node, "master" is set as hostname here.
echo "[$1]: Your hostname will be replaced by $1."
sudo hostnamectl set-hostname $1

# 2. ssh-keygen
echo "[$1]: Begin to do with ssh configuration."
echo "[$1]: (default file path and empty passphrase is used)"
# default type is RSA, passphrase is null, while file output-path is default
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa

# 3. Change /etc/hosts && ssh-copy-id
echo "[$1]: Begin to 'copy' your id_rsa.pub(public key used in ssh) to other machines."
read -p "Please input master's LAN-IP: " masterIP
read -p "Please input the number of slaves: " slaveNum
echo "$masterIP master" > .tmp.ipcfg
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$masterIP
i=1
while [ $i -le $slaveNum ]
do
    read -p "Please input the LAN-IP of a slave: " slaveIP
    read -p "Please input the number of above slave: " slaveNo
    echo "$slaveIP  slave$slaveNo" >> .tmp.ipcfg

    # distribute ssh public key
    ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$slaveIP
    ((i=i+1))
done
sudo bash -c "cat .tmp.ipcfg >> /etc/hosts"

# 4. Change /etc/apt/sources.list
# focal --> Ubuntu 20.04
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
sudo apt install openjdk-8-jdk-headless
if [ $(java -version 2>&1 | grep -c "openjdk version") -ge 1 ];then
    echo "jdk install successfully."
else
    echo "fail to install jdk. script exits."
    exit 1
fi

# 6. install hadoop
# file "hadoop-2.10.1.tar.gz" "contains" folder "hadoop-2.10.1".
# I use "wc" to check integrity of hadoop decompression.
#
# path "hadoop-2.10.1" should contain the following files:
# bin(d) etc(d) include(d) lib(d) libexec(d) LICESE.txt(f) NOTICE.txt(f) README.txt(f) sbin(d) share(d)
HADOOP_HOME=~/hadoop-2.10.1
# if ~/hadoop-2.10.1 exist, delete its content first.
if [ ! -d $HADOOP_HOME ];then
    # hadoop-2.10.1 have not been downloaded
    wget -P /tmp https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
    tar -xzf /tmp/hadoop-2.10.1.tar.gz -C ~
elif [ ! $(ls $HADOOP_HOME | wc -l) -eq 10 ];then
    # downloaded, but not integrate
    wget -P /tmp https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
    rm -r $HADOOP_HOME &&  tar -xzf /tmp/hadoop-2.10.1.tar.gz -C ~
else
    # perfect
    echo "[$1]: hadoop-2.10.1 exists."
fi
# check integrity
if [ $(ls $HADOOP_HOME | wc -l) -ne 10 ];then
    echo "fail to install hadoop correctly. script exits."
    exit 1
fi