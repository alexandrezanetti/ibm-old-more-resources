#!/bin/bash
echo $DIR_SHARED_NFS_SERVER
echo $USER_DIR_SHARED_NFS_SERVER
echo $GUSER_DIR_SHARED_NFS_SERVER

#Install NFS: https://www.tecmint.com/install-nfs-server-on-centos-8/ 
#http://wiki.r1soft.com/display/ServerBackup/Configure+NFS+server+on+Linux

if [ ${DIR_SHARED_NFS_SERVER} = "{###PROVIDE_YOUR_DIR_SHARED_NFS_SERVER_HERE###}" ]; then echo "Please provide your Directory to share on NFS "; exit 999; fi
if [ ${USER_DIR_SHARED_NFS_SERVER} = "{###PROVIDE_YOUR_USER_DIR_SHARED_NFS_SERVER_HERE###}" ]; then echo "Please provide your User to be owner of shared NFS "; exit 999; fi
if [ ${GUSER_DIR_SHARED_NFS_SERVER} = "{###PROVIDE_YOUR_GUSER_DIR_SHARED_NFS_SERVER_HERE###}" ]; then echo "Please provide your Group User of shared NFS "; exit 999; fi


#-ja esta no script-----------------
sudo dnf install -y nfs-utils nfs4-acl-tools 

export DIR_INST=/tmp/NFS/
mkdir -p $DIR_INST
chmod 777 $DIR_INST

echo "Discovering IPs" 
ip a | grep " 10." | grep inet > $DIR_INST/ipa10.txt
export IPA10IPWCIDR=$(awk '/ inet / {print $2}' $DIR_INST/ipa10.txt)
export IPA10IP=$(awk '/ inet / {print $2}' $DIR_INST/ipa10.txt | egrep -o '^[^/]+')
ip a | grep " 9." | grep inet > $DIR_INST/ipa9.txt
export IPA9IPCIDR=$(awk '/ inet / {print $2}' $DIR_INST/ipa9.txt)
export IPA9IP=$(awk '/ inet / {print $2}' $DIR_INST/ipa9.txt | egrep -o '^[^/]+')
echo $IPA10IPWCIDR
echo $IPA10IP
echo $IPA9IPCIDR
echo $IPA9IP

#Criando o user
groupadd $USER_DIR_SHARED_NFS_SERVER
useradd $USER_DIR_SHARED_NFS_SERVER -g $GUSER_DIR_SHARED_NFS_SERVER
usermod -a -G $GUSER_DIR_SHARED_NFS_SERVER $USER_DIR_SHARED_NFS_SERVER
usermod -a -G $GUSER_DIR_SHARED_NFS_SERVER root
id $USER_DIR_SHARED_NFS_SERVER 
id root
cat /etc/passwd | grep "$USER_DIR_SHARED_NFS_SERVER \|root"
cat /etc/group | grep "$GUSER_DIR_SHARED_NFS_SERVER"

#-novo-----------------
mkdir -p $DIR_SHARED_NFS_SERVER
chmod 666 $DIR_SHARED_NFS_SERVER
sudo chown -R $USER_DIR_SHARED_NFS_SERVER:$USER_DIR_SHARED_NFS_SERVER $DIR_SHARED_NFS_SERVER
sudo chmod -R ug+rwx $DIR_SHARED_NFS_SERVERd

cp /etc/exports $DIR_INST/exports.backup
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/s1-nfs-server-config-exports
export nfsline="$DIR_SHARED_NFS_SERVER       *(rw,sync,no_wdelay,root_squash,insecure,no_subtree_check,fsid=0)"
#                                             (rw,sync,no_root_squash,insecure,no_subtree_check)
echo $nfsline

cat $DIR_INST/exports.backup | sed -z 's/\n\n/\n/g' > /etc/exports 
echo $nfsline >> /etc/exports

cat /etc/exports 

systemctl start nfs-server.service
systemctl enable nfs-server.service
systemctl status nfs-server.service
exportfs -arv
exportfs -s
systemctl restart nfs-server.service

systemctl start firewalld
firewall-cmd --permanent --add-service nfs
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --permanent --add-service mountd
firewall-cmd --reload
#firewalld --permanent --add-service=nfs
#firewalld --permanent --add-service=rpc-bind
#firewalld --permanent --add-service=mountd
#firewalld --reload
systemctl restart firewalld
systemctl stop firewalld

exportfs -arv
exportfs -s

echo "##############################################"
echo "##############################################"
echo "NFS montado no arquivo: cat /etc/exports"
echo "Use este comando na máquina que será NFS cliente:"
echo "   sudo dnf install -y nfs-utils nfs4-acl-tools ; showmount -e $IPA9IP"  
showmount -e $IPA9IP
echo "##############################################"
echo "##############################################"
