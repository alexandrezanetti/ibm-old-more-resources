#!/bin/bash

echo $PROJECT
echo $DIR_SHARED_NFS_SERVER
echo $IP_NFS_SERVER

mkdir -p /tmp/nfs/$PROJECT/ocpPvPvcNfs
chmod a+x /tmp/nfs/$PROJECT/ocpPvPvcNfs

cat ~/more-resources/nfs/ocpPvNfs.yaml | sed "s/{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}/${PROJECT}/g" |  sed "s/{###PROVIDE_YOUR_DIR_SHARED_NFS_SERVER_HERE###}/${DIR_SHARED_NFS_SERVER}/g" | sed "s/{###PROVIDE_YOUR_IP_NFS_SERVER_HERE###}/${IP_NFS_SERVER}/g" >/tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvNfs_OK.yaml
oc apply -f /tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvNfs_OK.yaml

cat ~/more-resources/nfs/ocpPvcNfs.yaml | sed "s/{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}/${PROJECT}/g"  >/tmp/nfs/$PROJECT/ocpPvPvcNfs/ocpPvcNfs_OK.yaml
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
