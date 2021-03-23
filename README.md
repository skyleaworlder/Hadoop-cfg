# :elephant: Hadoop-2.10.1 Auto-Config

## :microphone: Intro

Quick-Start scripts. *.sh about Hadoop 2.10.1 config on Ubuntu 20.04.

To help, build a "Simple Hadoop Cluster".

## :watermelon: Env

|Key|Value|
|-|-|
| Time | 2021-03-22 |
| ECS Provider| UCloud |
| OS | Ubuntu 20.04 LTS |
| vCPU | 2 |
| RAM | 4 GB |
| Java Version | 1.8.0_282 |
| Hadoop Version | 2.10.1 |

## :hammer: Usage

### :one: clone this repo

```bash
# on your PC
git clone https://github.com/skyleaworlder/Hadoop-cfg
# e.g. scp -r ./Hadoop-cfg ubuntu@101.23.120.133:/home/ubuntu
scp -r ./Hadoop-cfg [your-username]@[your-WAN-IP]:/home/[your-user]
```

### :two: init

```bash
# both on your master and slaves
cd ~/Hadoop-cfg
sudo chmod 744 node_before_script.sh

# In this script, you should input the value of some important variables.
# e.g. master LAN-IP, the number of slaves, slave LAN-IPs...
./node_before_script.sh
```

You can do a check job by executing the following instructions:

* cat /etc/hosts
* cat /etc/apt/sources.list
* cat ~/.ssh/authorized_keys
* cat ~/.ssh/known_hosts
* java -version

### :three: slaves

```bash
# on your slave nodes
sudo chmod 744 slave_hadoop_cfg.sh
source slave_hadoop_cfg.sh
```

You can check it by:

* tail -n 5 ~/.bashrc
* echo $PATH

### :four: master

```bash
# on your master node
sudo chmod 744 master_hadoop_cfg.sh
source master_hadoop_cfg.sh
```

You can check the result of this script on **MASTER** by executing:

* cat ~/hadoop-2.10.1/etc/slaves
* tail -n 5 ~/hadoop-2.10.1/etc/hadoop-env.sh
* tail -n 5 ~/.bashrc
* echo $PATH

and on **SLAVE** you can do:

* ls ~/hadoop-2.10.1
* cat ~/.ssh/known_hosts

### :five: format and start

```bash
# on your master node
hdfs namenode -format
start-dfs.sh
```

You can check whether Hadoop starts or not:

```bash
# on your master node
jps

# jps's output contain "Jps", "NameNode", "SecondaryNameNode" and "DataNode".
```

```bash
# on your slave node
jps

# the output contain "Jps" and "DataNode".
```

## :mega: Notice

Folder `etc` and its contents are "uploaded" to curricula group by Prof.Deng.
