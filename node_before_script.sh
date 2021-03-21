hostname=$1

echo "[$1]: Your hostname will be replaced by $1."
sudo hostnamectl set-hostname $1

echo "[$1]: Begin to do with ssh configuration."
echo "[$1]: (default file path and empty passphrase is used)"
# default type is RSA, passphrase is null, while file output-path is default
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa

echo "[$1]: Begin to 'copy' your id_rsa.pub(public key used in ssh) to other machines."
read -p "Please input master's LAN-IP: " masterIP
read -p "Please input the number of slaves: " slaveNum
i=1
echo > .tmp.ipcfg
while [ $i -le $slaveNum ]
do
    echo "Please input the LAN-IP of No.$i slave:" slaveIP
    echo "$slaveIP  slave$i" >> .tmp.ipcfg
done
# append /etc/hosts
sudo cat .tmp.ipcfg >> /etc/hosts