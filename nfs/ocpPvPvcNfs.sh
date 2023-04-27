#!/bin/bash

echo $PROJECT
echo $DIR_SHARED_NFS_SERVER
echo $IP_NFS_SERVER
echo $BASTION_NFS_SERVER

if [ ${PROJECT} = "{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}" ]; then echo "Please provide your Namespace"; exit 999; fi
if [ ${DIR_SHARED_NFS_SERVER} = "{###PROVIDE_YOUR_DIR_SHARED_NFS_SERVER_HERE###}" ]; then echo "Please provide your Directory to share on NFS "; exit 999; fi
if [ ${BASTION_NFS_SERVER} = "{###TRUE/FALSE###}" ]; then echo "Please provide your NFS Server will install on Bastion? TRUE/FALSE"; exit 999; fi

if [ ${BASTION_NFS_SERVER} = TRUE ]; then 
   echo "Discovering IPs" ;
   ip a | grep " 10." | grep inet > $DIR_INST/ipa10.txt ;
   export IPA10IPWCIDR=$(awk '/ inet / {print $2}' $DIR_INST/ipa10.txt) ;
   export IPA10IP=$(awk '/ inet / {print $2}' $DIR_INST/ipa10.txt | egrep -o '^[^/]+') ;
   ip a | grep " 9." | grep inet > $DIR_INST/ipa9.txt ;
   export IPA9IPCIDR=$(awk '/ inet / {print $2}' $DIR_INST/ipa9.txt) ;
   export IPA9IP=$(awk '/ inet / {print $2}' $DIR_INST/ipa9.txt | egrep -o '^[^/]+') ;
   echo $IPA10IPWCIDR ;
   echo $IPA10IP ;
   echo $IPA9IPCIDR ;
   echo $IPA9IP ;
   export IP_NFS_SERVER=$IPA9IP ;
fi
echo $IP_NFS_SERVER

if [ ${IP_NFS_SERVER} = "{###PROVIDE_YOUR_IP_NFS_SERVER_HERE###}" ]; then echo "Please provide your NFS Server IP "; exit 999; fi
echo $IP_NFS_SERVER

mkdir -p /tmp/nfs/$PROJECT/ocpPvPvcNfs
chmod a+x /tmp/nfs/$PROJECT/ocpPvPvcNfs
export DIR_INST=/tmp/nfs/$PROJECT/ocpPvPvcNfs

cat ~/more-resources/nfs/ocpPvNfs.yaml | sed "s/{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}/${PROJECT}/g" | sed "s|{###PROVIDE_YOUR_DIR_SHARED_NFS_SERVER_HERE###}|${DIR_SHARED_NFS_SERVER}|g" | sed "s/{###PROVIDE_YOUR_IP_NFS_SERVER_HERE###}/${IP_NFS_SERVER}/g" >/tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvNfs_OK.yaml
oc apply -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvNfs_OK.yaml

cat ~/more-resources/nfs/ocpPvcNfs.yaml | sed "s/{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}/${PROJECT}/g" >/tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvcNfs_OK.yaml
oc apply -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvcNfs_OK.yaml

echo "Para deletar: "
echo "oc delete -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvNfs_OK.yaml"
echo "oc delete -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvcNfs_OK.yaml"
echo "Ou execute o script: /tmp/nfs/$PROJECT/ocpPvPvcNfs/./nfs_uninstall.sh"

cat <<EOF > /tmp/nfs/$PROJECT/ocpPvPvcNfs/./nfs_uninstall.sh
oc delete -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvNfs_OK.yaml
oc delete -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvcNfs_OK.yaml
EOF
chmod 777 /tmp/nfs/$PROJECT/ocpPvPvcNfs/./nfs_uninstall.sh
