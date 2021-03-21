# > master.sh [LAN-masterIP] [LAN-slave1IP]
# the first parameter is master's IP;
# the second parameter is slave's IP.
# e.g.
# > master.sh 10.23.57.99 10.23.74.76 10.23.23.169
# TODO: add slave2
masterIP=$1
slave1IP=$2

# 1. Change hostname of ECS
# e.g. if IP of your UCloud-ECS is 10.23.169.137, your hostname will be 10-23-159-192
# you can execute "hostname" over SSH to get the hostname of your ECS
# For master node, "master" is set as hostname here.
sudo hostnamectl set-hostname master

# create a folder to make a backup for some "etc" files
BAK_PATH=~/hadoop_bak
sudo mkdir $BAK_PATH
sudo cp /etc/hosts $BAK_PATH
sudo cp /etc/apt/source.list $BAK_PATH
sudo cp ~/.bashrc $BAK_PATH

# 2. Change /etc/hosts
(
sudo cat <<EOF
${masterIP}  master
${slave1IP}  slave1
EOF
) >> /etc/hosts

# 3. Change /etc/apt/source.list
# focal --> Ubuntu 20.04
(
sudo cat <<EOF
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
) > /etc/apt/source.list
sudo apt-get update
sudo apt-get upgrade

# 4. install jdk
sudo apt install openjdk-8-jdk-headless
if [ $(java -version | grep -c "openjdk version") -gt 1 ];then
    echo "jdk install successfully."
else
    echo "fail to install jdk. script exits."
    exit 1
fi

# 5. install hadoop
# file "hadoop-2.10.1.tar.gz" "contains" folder "hadoop-2.10.1".
# I use "wc" to check integrity of hadoop decompression.
#
# path "hadoop-2.10.1" should contain the following files:
# bin(d) etc(d) include(d) lib(d) libexec(d) LICESE.txt(f) NOTICE.txt(f) README.txt(f) sbin(d) share(d)
wget -P /tmp https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
HADOOP_HOME="~/hadoop-2.10.1"
# if ~/hadoop-2.10.1 exist, delete its content first.
if [ ! -d $HADOOP_HOME ];then
    tar -xzf /tmp/hadoop-2.10.1.tar.gz -C ~
else
    rm -r $HADOOP_HOME &&  tar -xzf /tmp/hadoop-2.10.1.tar.gz -C ~
fi
# check integrity
if [ $(ls $HADOOP_HOME | wc -l) -eq 10 ];then
    echo "hadoop install and extract successfully."
else
    ehco "fail to install hadoop correctly. script exits."
    exit 1
fi

# 6. hadoop configuration
cp $HADOOP_HOME/etc/hadoop $BAK_PATH
# 6.1 about env
# TODO: add slave2
echo "export PATH=$PATH:/home/$USER/hadoop-2.10.1/bin:/home/$USER/hadoop2.10.1/sbin" >> ~/.bashrc
source ~/.bashrc
# 6.2 HADOOP_HOME/etc/hadoop/slaves
(
sudo cat <<EOF
slave1
master
EOF
) > $HADOOP_HOME/etc/hadoop/slaves
# 6.3 core-site.xml & hadoop-env & hdfs-site
cp ./etc/core-site.xml $HADOOP_HOME/etc/hadoop
cp ./etc/hadoop-env.sh $HADOOP_HOME/etc/hadoop
cp ./etc/hdfs-site.xml $HADOOP_HOME/etc/hadoop
# 6.4 yarn-site
cp ./etc/yarn-site.xml $HADOOP_HOME/etc/hadoop

# 7. slave1
cd ~
scp -r hadoop-2.10.1 ubuntu@slave1:/home/ubuntu/hadoop-2.10.1