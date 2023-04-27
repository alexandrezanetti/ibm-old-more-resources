#!/bin/bash

echo $PROJECT
echo $STORAGECLASSBLOCK
echo $APICLICENCE

mkdir -p /tmp/$PROJECT/apiconnectInstance
chmod a+x /tmp/$PROJECT/apiconnectInstance

cat ~/more-resources/nfs/ocpPvNfs.yaml | sed "s/{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}/${PROJECT}/g" |  sed "s/{###PROVIDE_YOUR_DIR_SHARED_NFS_SERVER_HERE###}/${DIR_SHARED_NFS_SERVER}/g" | sed "s/{###PROVIDE_YOUR_IP_NFS_SERVER_HERE###}/${IP_NFS_SERVER}/g" >/tmp/nfs/ocpPvNfs_OK.yaml
oc apply -f /tmp/nfs/ocpPvNfs_OK.yaml

cat ~/more-resources/nfs/ocpPvcNfs.yaml | sed "s/{###PROVIDE_YOUR_PROJECT_NAMESPACE_CP4X_HERE###}/${PROJECT}/g" |  sed "s/{###PROVIDE_YOUR_DIR_SHARED_NFS_SERVER_HERE###}/${DIR_SHARED_NFS_SERVER}/g" | sed "s/{###PROVIDE_YOUR_IP_NFS_SERVER_HERE###}/${IP_NFS_SERVER}/g" >/tmp/nfs/ocpPvcNfs_OK.yaml
oc apply -f /tmp/nfs/ocpPvcNfs_OK.yaml

