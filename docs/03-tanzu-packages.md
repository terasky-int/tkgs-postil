# Install Tanzu Packages

## Add Package Repository
First, add the standard package repository to your cluster. This repository contains all the available Tanzu packages.

```bash
tanzu package repository add standard-repo --url harbor-01.ipa-bs.org/tanzu-packages/packages/standard/repo:v2025.4.29 -n tkg-system
```

## List Available Packages
To see all available packages in the repository:

```bash
tanzu package available list
```

## Install Cert-Manager
Cert-manager is required for managing TLS certificates in your cluster. It's a prerequisite for many other packages.

```bash
tanzu package install cert-manager -p cert-manager.tanzu.vmware.com -v 1.17.1+vmware.1-tkg.1 -n tanzu-packages
```


## Get Package Details
To get detailed information about a specific package, including its configuration options:

```bash
tanzu package available get contour.tanzu.vmware.com
```

## Install Contour
Contour is an ingress controller that provides advanced routing capabilities. You can install it in two ways:

1. Basic installation with default settings:
```bash
tanzu package install contour -p contour.tanzu.vmware.com -v 1.30.2+vmware.2-tkg.1 -n tanzu-packages
```

2. Custom installation with a values file:
```bash
tanzu package install contour -p contour.tanzu.vmware.com -v 1.30.2+vmware.2-tkg.1 -n tanzu-packages --values-file contour-values.yaml
```
