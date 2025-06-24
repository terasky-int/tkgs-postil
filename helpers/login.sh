export VSPHERE_NAMESPACE=$1
export CLUSTER_NAME=$2
export USER_NAME=administrator@vsphere.local
#export KUBECTL_VSPHERE_PASSWORD=
export TANZU_SERVER=172.16.92.4
 
# Construct the kubectl vsphere login command
LOGIN_CMD="kubectl vsphere login \
--server ${TANZU_SERVER} \
-u ${USER_NAME} \
--tanzu-kubernetes-cluster-namespace ${VSPHERE_NAMESPACE} \
--insecure-skip-tls-verify"
 
# Check if CLUSTER_NAME is provided
if [ -n "$CLUSTER_NAME" ]; then
  LOGIN_CMD+=" --tanzu-kubernetes-cluster-name ${CLUSTER_NAME}"
fi
 
# Execute the login command
eval $LOGIN_CMD