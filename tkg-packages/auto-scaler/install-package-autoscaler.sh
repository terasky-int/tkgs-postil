#######################
# - Create a new TKG cluster, or update an existing TKG cluster, with autoscaler annotations and remove the replicas field in spec.topology.workers.machinedeployments.
# - The minimum vSphere version is vSphere 8 U3
# - The minimum TKr version is TKr 1.27.x for vSphere 8
# - The minor version of the TKr and the minor version of the Cluster Autoscaler package must match

#######################

export CLUSTER_NAME=mob-wlc-dev
export VSPHERE_NAMESPACE=dev-ns
export USER_NAME=administrator@vsphere.local
export KUBECTL_VSPHERE_PASSWORD=xxxxxx
export TANZU_SERVER=172.16.92.3

 k vsphere login \
 --server ${TANZU_SERVER} \
 -u ${USER_NAME} \
 --tanzu-kubernetes-cluster-namespace ${VSPHERE_NAMESPACE} \
 --tanzu-kubernetes-cluster-name ${CLUSTER_NAME} \
  --insecure-skip-tls-verify 

tanzu plugin install --group vmware-vsphere/default:v8.0.3

tanzu package repository add standard-repo --url projects.registry.vmware.com/tkg/packages/standard/repo:v2024.8.21 -n tkg-system
tanzu package available list -n tkg-system
tanzu package available get cluster-autoscaler.tanzu.vmware.com -n tkg-system

tanzu package available get cluster-autoscaler.tanzu.vmware.com/1.27.2+vmware.1-tkg.3  -n tkg-system --default-values-file-output values.yaml

cat > values.yaml <<-EOF
arguments:  
  ignoreDaemonsetsUtilization: true  
  maxNodeProvisionTime: 15m  
  maxNodesTotal: 0  
  metricsPort: 8085  
  scaleDownDelayAfterAdd: 10m  
  scaleDownDelayAfterDelete: 10s  
  scaleDownDelayAfterFailure: 3m  
  scaleDownUnneededTime: 10m
clusterConfig:  
  clusterName: "${CLUSTER_NAME}"  
  clusterNamespace: "${VSPHERE_NAMESPACE}"
paused: false
EOF


tanzu package install cluster-autoscaler-pkgi -n tkg-system --package cluster-autoscaler.tanzu.vmware.com --version 1.27.2+vmware.1-tkg.3 --values-file values.yaml