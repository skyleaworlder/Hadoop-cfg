#!/bin/bash
# slave only need to do with env config.
# hadoop-2.10.1 is prepared by master node.
HADOOP_HOME=~/hadoop-2.10.1
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
source ~/.bashrc
