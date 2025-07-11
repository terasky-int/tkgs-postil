# Install Tanzu Packages

## Add Package Repository
First, add the standard package repository to your cluster. This repository contains all the available Tanzu packages. The repository is hosted in your private Harbor registry.

```bash
tanzu package repository add standard-repo --url harbor-01.ipa-bs.org/tanzu-packages/packages/standard/repo:v2025.4.29 -n tkg-system
```

## Create Package Namespace
Create a dedicated namespace for Tanzu packages. This namespace will be used to install and manage all your Tanzu packages.

```bash
kubectl create ns tanzu-packages
```

## List Available Packages
To see all available packages in the repository. This command will show you all packages that can be installed, along with their versions and descriptions.

```bash
tanzu package available list
```

## Get Package Details
To get detailed information about a specific package, including its configuration options, prerequisites, and available versions. This is useful before installing a package to understand its requirements and configuration options.

```bash
tanzu package available get contour.tanzu.vmware.com
```

## Change to Package Directory
Before installing any packages, change to the directory containing the package configuration files:

```bash
cd /home/k8s/tanzu-packages
```




## Install Cert-Manager
Cert-manager is required for managing TLS certificates in your cluster. It's a prerequisite for many other packages, especially those that require HTTPS/TLS termination.

```bash
tanzu package install cert-manager -p cert-manager.tanzu.vmware.com -v 1.17.1+vmware.1-tkg.1 -n tanzu-packages
```

## Install Contour
Contour is an ingress controller that provides advanced routing capabilities. You can install it in two ways:

Custom installation with a values file:
```bash
tanzu package install contour -p contour.tanzu.vmware.com -v 1.30.2+vmware.2-tkg.1 -n tanzu-packages --values-file contour-values.yaml
```

## Install Cluster Autoscaler

### Prerequisites
Before installing the cluster autoscaler, ensure you meet the following requirements:
- vSphere 8 U3 or later
- TKr 1.27.x or later for vSphere 8
- The minor version of the TKr and the minor version of the Cluster Autoscaler package must match

### Get Available Versions
First, list the available package versions to find the correct version for your cluster:

```bash
tanzu package available get cluster-autoscaler.tanzu.vmware.com -n tkg-system
```

### Create Values File
Create a values file for the cluster autoscaler configuration:

```bash
export CLUSTER_NAME=your-cluster-name
export VSPHERE_NAMESPACE=your-vsphere-namespace
```

```bash
cat > cluster-autoscaler-values.yaml <<-EOF
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

```bash
mv cluster-autoscaler-values.yaml <CLUSTER-NAME>-autoscaler-values.yaml
```

### Install Cluster Autoscaler
Install the cluster autoscaler package with the appropriate version:

```bash
tanzu package install cluster-autoscaler-pkgi \
--package cluster-autoscaler.tanzu.vmware.com \
--version 1.27.2+vmware.1-tkg.3 \
--values-file <CLUSTER-NAME>-autoscaler-values.yaml \
--namespace tanzu-packages 
```

**Important**: Replace the version with the one that matches your TKr version. The minor version of the TKr and the minor version of the Cluster Autoscaler package must match.

## Verify Installation
After installing packages, you can verify their status using:

```bash
# Check package repository status
tanzu package repository list -A

# Check installed packages
tanzu package installed list -A

# Check specific package status
tanzu package installed get cert-manager -n tanzu-packages
tanzu package installed get contour -n tanzu-packages
tanzu package installed get cluster-autoscaler-pkgi -n tanzu-packages
```

## Common Operations

### Update a Package
To update an installed package to a newer version:

```bash
tanzu package installed update <package-name> --version <new-version> -n tanzu-packages
```

### Delete a Package
To remove an installed package:

```bash
tanzu package installed delete <package-name> -n tanzu-packages
```

### Troubleshooting
If you encounter issues with package installation:

1. Check the package repository status:
```bash
tanzu package repository list -A
```

2. Check the package installation status:
```bash
tanzu package installed list -A
```

3. For cluster autoscaler issues, verify version compatibility:
```bash
# Check TKr version
kubectl get tkr

# Check cluster autoscaler version
tanzu package installed get cluster-autoscaler-pkgi -n tanzu-packages
```

## Related Documentation

- [Cluster Autoscaling](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-9DEE9694-81E3-4895-BA66-7A45F3E69894.html)



