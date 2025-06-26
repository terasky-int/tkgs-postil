# Deploy cluster-autoscaler

## Version Requirements
Cluster autoscaler has the following version requirements.
- The minimum vSphere version is vSphere 8 U3
- The minimum TKr version is TKr 1.27.x for vSphere 8
- The minor version of the TKr and the minor version of the Cluster Autoscaler package must match


Set the context of kubectl to the relevant cluster. For example:

```bash
kubectx mob-wlc-dev
```

Retrieve all the version of the available package.

First we will need to list the repository versions by running the following command.

```bash
imgpkg tag list -i projects.registry.vmware.com/tkg/packages/standard/repo
```
This is the output.

```output
┌── k8s@k8s ~  (⎈|mob-wlc-dev:N/A)
└─> imgpkg tag list -i projects.registry.vmware.com/tkg/packages/standard/repo
Tags

Name  
external-dns-56b81f2149f1cc6  
v0.10.0_vmware.1-tkg.4  
v1.4.0  
v1.4.1  
v1.4.2  
v1.4.3  
v1.5.0  
v1.5.0-tf-v0.10.1  
v1.5.1-tf-v0.11.2  
v1.5.2  
v1.5.3  
v1.5.4  
v1.5.4-update.1  
v1.5.4-update.2  
v1.6.0  
v1.6.0-update.1  
v1.6.1  
v1.6.1_update.1  
v2.1.0  
v2.1.1  
v2.1.1_update.1  
v2.1.1_update.2  
v2.2.0  
v2.2.0_update.1  
v2.2.0_update.2  
v2023.10.16  
v2023.11.21  
v2023.7.13  
v2023.7.13_update.1  
v2023.7.13_update.2  
v2023.7.31_update.1  
v2023.9.19  
v2023.9.19_update.1  
v2024.2.1  
v2024.2.1_tmc.1  
v2024.4.12  
v2024.4.19  
v2024.5.14  
v2024.5.16  
v2024.6.27  
v2024.7.11  
v2024.7.2  
v2024.8.21  

43 tags

Succeeded
```

Log in to the cluster.

```bash
kubectl vsphere login --server=IP-or-FQDN --vsphere-username USER@vsphere.local --tanzu-kubernetes-cluster-name CLUSTER --tanzu-kubernetes-cluster-namespace VSPHERE-NS
```

Create the package repository.

```bash
tanzu package repository add standard-repo --url projects.registry.vmware.com/tkg/packages/standard/repo:v2024.8.21 -n tkg-system
```

List the available packages.

tanzu package available list -n tkg-system
tanzu package available get cluster-autoscaler.tanzu.vmware.com -n tkg-system
tanzu package available get cluster-autoscaler.tanzu.vmware.com/1.27.2+vmware.1-tkg.3  -n tkg-system --default-values-file-output values.yaml

```

Create the namespace.

```bash
kubectl create namespace tkg-packages
```

```bash
export CLUSTER_NAME=mob-wlc-dev
export VSPHERE_NAMESPACE=dev-ns

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
```

Install the package.

```bash
tanzu package install cluster-autoscaler-pkgi \
--package cluster-autoscaler.tanzu.vmware.com \
--version 1.27.2+vmware.1-tkg.3 \
--values-file values.yaml \
--namespace tkg-packages 
```

Note: The minor version of the TKr and the minor version of the Cluster Autoscaler package must match.


Reference:

- [Cluster Autoscaling](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-9DEE9694-81E3-4895-BA66-7A45F3E69894.html)
