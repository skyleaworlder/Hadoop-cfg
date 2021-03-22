# Hadoop-2.10.1 Config

## Intro

To help, build a "simple hadoop cluster".

## Env

* Time: 2021-03-22
* ECS Provider: UCloud
* OS: Ubuntu 20.04 LTS
* Cfg: 2 vCPU, 4G RAM
* Java jdk: 1.8.0_282
* Hadoop: 2.10.1

## Usage

### 1. clone this repo

```bash
# on your PC
git clone https://github.com/skyleaworlder/Hadoop-cfg
scp -r ./Hadoop-cfg [your-username]@[your-WAN-IP]:/home/[your-user]
```

### 2. init

```bash
# both on your master and slaves
cd ~/Hadoop-cfg
sudo chmod 744 node_before_script.sh

# "master" or "slave1" / "slave2" / ... are recommended
# as the first parameter of "node_before_script"
./node_before_script.sh [machine-hostname]
```

You can do a check job by executing the following instructions:

* cat /etc/hosts
* cat /etc/apt/sources.list
* cat ~/.ssh/authorized_keys
* cat ~/.ssh/known_hosts
* java -version

### 3. slaves

```bash
# on your slave nodes
sudo chmod 744 slave_hadoop_cfg.sh
source slave_hadoop_cfg.sh
```

You can check it by:

* tail -n 5 ~/.bashrc
* echo $PATH

### 4. master

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

### 5. format and start

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

## Notice

Folder `etc` and its contents are "uploaded" to curricula group by Prof.Deng.
