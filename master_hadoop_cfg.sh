#!/bin/bash
# This is a script to finish configuration about hadoop
# - step: 0
#   target: download hadoop
#       - check integrity
# - step: 1
#   target: hadoop config
#       - backup
#       - env
#       - slaves
#       - core-site.xml & hdfs-site.xml & yarn-site.xml
#       - hadoop-env.sh
# - step: 2
#   target: distribute hadoop

# 0. install hadoop
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
    echo "[$USER]: hadoop-2.10.1 exists."
fi
# check integrity
if [ $(ls $HADOOP_HOME | wc -l) -ne 10 ];then
    echo "[$USER]: fail to install hadoop correctly. script exits."
    exit 1
fi

# 1. make a backup about hadoop etc
#   ~/.hadoop.bak.d/:
#       - .bashrc: ~/.bashrc
#       - hadoop/: ~/hadoop-2.10.1/etc/hadoop
#       - hosts: /etc/hosts
#       - sources.list: /etc/apt/sources.list
BAK_PATH=~/.hadoop.bak.d
cp $HADOOP_HOME/etc/hadoop $BAK_PATH

# 2. about env
echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> ~/.bashrc
source ~/.bashrc

# 3. about slave
awk '{ print "echo", $2, ">> .tmp.slaves" | "bash" }' .tmp.ipcfg
cat .tmp.slaves > $HADOOP_HOME/etc/hadoop/slaves
rm .tmp.slaves

# 4. core-site.xml & hdfs-site.xml & yarn-site.xml
cp ./etc/core-site.xml $HADOOP_HOME/etc/hadoop
cp ./etc/hdfs-site.xml $HADOOP_HOME/etc/hadoop
cp ./etc/yarn-site.xml $HADOOP_HOME/etc/hadoop

# 5. about hadoop-env.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# 6. distribute hadoop and its configuration
HADOOP_HOME=~/hadoop-2.10.1
while read LINE
do
    if [ $LINE = "master" ];then
        echo "[$USER]: --> master, master node do not need to distribute."
        echo
    else
        echo "[$USER]: --> $LINE, begin to distribute hadoop..."
        scp -r $HADOOP_HOME ubuntu@$LINE:~
        echo "[$USER]: --> $LINE, finish distributing."
        echo
    fi
done < $HADOOP_HOME/etc/hadoop/slaves