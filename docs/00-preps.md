# Preparation steps for vSphere with Tanzu deployment

This document outlines the preparation steps required to set up vSphere with Tanzu in an air-gapped environment. The process involves downloading necessary components from an internet-connected machine and then transferring them to the admin VM.

## Prerequisites

- Windows or Linux machine with internet access
- Admin VM in your vSphere with Tanzu environment
- Access to a container registry (Harbor recommended)
- Docker installed on the admin VM

## Phase 1: Download components from internet-connected machine

### Step 1: Install Tanzu CLI

Download and install the Tanzu CLI from the official VMware GitHub releases:

```bash
# Visit the releases page and download the appropriate version for your OS
https://github.com/vmware-tanzu/tanzu-cli/releases
```

### Step 2: Install vSphere plugin

Install the VMware vSphere plugin for Tanzu CLI:

```bash
tanzu plugin install --group vmware-vsphere/default:v8.0.3
```

### Step 3: Check available package versions

List available versions of Tanzu packages in the VMware registry:

```bash
tanzu imgpkg tag list -i projects.registry.vmware.com/tkg/packages/standard/repo
```

### Step 4: Download Tanzu packages

Download the Tanzu packages bundle to a local tar file. Replace `v2025.4.29` with your desired version from the previous step:

```bash
tanzu imgpkg copy -b projects.registry.vmware.com/tkg/packages/standard/repo:v2025.4.29 --to-tar ./tanzu-packages-v2025.4.29.tar
```

### Step 5: Download plugin bundle

Download the Tanzu Kubernetes Grid plugin bundle:

```bash
tanzu plugin download-bundle --group vmware-tkg/default:v2.5.2 --to-tar plugin-bundle-tkg.tar.gz
```

### Step 6: Download TKG service package

Download the TKG service package with signature verification:

```bash
tanzu imgpkg copy -b projects.packages.broadcom.com/vsphere/iaas/tkg-service/3.1.0/tkg-service:3.1.0 --to-tar tkg-service-v3.1.0.tar --cosign-signatures
```

## Phase 2: Transfer files to admin VM

Copy the following files from your internet-connected machine to the admin VM:

- `tanzu-packages-v2025.4.29.tar` - Tanzu packages bundle
- `plugin-bundle-tkg.tar.gz` - Plugin bundle for Tanzu Kubernetes Grid
- `tkg-service-v3.1.0.tar` - TKG service package

---

## Phase 3: Configure admin VM

### Step 1: Update plugin source

Configure the plugin source to use your local registry. Replace `registry.example.com` with your actual registry endpoint:

```bash
tanzu plugin source update default --uri registry.example.com/tanzu/plugin-inventory:latest
```

### Step 2: Configure SSL certificates

Add Harbor OVA certificate to trusted certificates for secure communication:

```bash
sudo cp harbor-ova.crt /usr/local/share/ca-certificates 
sudo update-ca-certificates
systemctl reload docker
systemctl restart docker
```

### Step 3: Configure registry access

Login to your container registry and set environment variables:

```bash
# Login to your registry
docker login <repo-endpoint>

# Set environment variables for registry access
export IMGPKG_REGISTRY_HOSTNAME_1=<repo_url>
export IMGPKG_REGISTRY_USERNAME_1=<username>
export IMGPKG_REGISTRY_PASSWORD_1=<password>
```

### Step 4: Copy packages to local registry

Copy the downloaded Tanzu packages to your local registry. Replace `<path-to-tarball>` and `<project-name>` with your actual values:

```bash
imgpkg copy --tar /<path-to-tarball>/tanzu-packages.tar --to-repo $IMGPKG_REGISTRY_HOSTNAME_1/<project-name>/packages/standard/repo
```

### Step 5: Copy TKG service to local registry

Copy the TKG service package to your local registry. Replace `harbor.example.com` with your actual registry endpoint:

```bash
imgpkg copy --tar tkg-service-v3.1.0.tar --to-repo harbor.example.com/tkgs/tkg-service --cosign-signatures --registry-ca-cert-path ca.crt
```

## Next steps

After completing these preparation steps, you can proceed with the vSphere with Tanzu deployment using the local registry components.
