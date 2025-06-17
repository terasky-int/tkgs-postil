# Run on windows/linux connected to the internet

## Step 1: Install Tanzu CLI
Download and install the Tanzu CLI from the official VMware GitHub releases   
This is required to interact with Tanzu Kubernetes Grid   
https://github.com/vmware-tanzu/tanzu-cli/releases   

## Step 2: Install Required Plugins
Install the VMware vSphere plugin for Tanzu CLI
This plugin provides vSphere-specific commands for managing Tanzu Kubernetes Grid
```bash
tanzu plugin install --group vmware-vsphere/default:v8.0.3
```
## Step 3: Check Available Package Versions
List available versions of Tanzu packages in the VMware registry
This helps in selecting the appropriate version for your environment
```bash
tanzu imgpkg tag list -i projects.registry.vmware.com/tkg/packages/standard/repo
```
## Step 4: Download Tanzu Packages
Download the Tanzu packages bundle to a local tar file
Replace v2025.4.29 with your desired version from the previous step
```bash
tanzu imgpkg copy -b projects.registry.vmware.com/tkg/packages/standard/repo:v2025.4.29 --to-tar ./tanzu-packages-v2025.4.29.tar
```
## Step 5: Download Plugin Bundle
Download the Tanzu Kubernetes Grid plugin bundle
This contains additional plugins needed for TKG operations
```bash
tanzu plugin download-bundle --group vmware-tkg/default:v2.5.2 --to-tar plugin-bundle-tkg.tar.gz
```

---
# Copy Files to Admin VM
Copy the downloaded tar files from your local machine to the Admin VM

### Copy the Tanzu packages tar file
tanzu-packages-v2025.4.29.tar 

### Copy the plugin bundle tar file  
plugin-bundle-tkg.tar.gz 

---
# Run on Admin VM

## Step 1: Update Plugin Source
Configure the plugin source to use your local registry
Replace registry.example.com with your actual registry endpoint
tanzu plugin source update default --uri registry.example.com/tanzu/plugin-inventory:latest

## Step 2: Download TKG Service Package
Download the TKG service package with signature verification
This package contains the TKG service components
imgpkg copy -b projects.packages.broadcom.com/vsphere/iaas/tkg-service/3.1.0/tkg-service:3.1.0 --to-tar tkg-service-v3.1.0.tar --cosign-signatures

## Step 3: Configure SSL Certificates
Add Harbor OVA certificate to trusted certificates
This is required for secure communication with the registry
sudo cp harbor-ova.crt /usr/local/share/ca-certificates 
sudo update-ca-certificates
systemctl reload docker
systemctl restart docker

## Step 4: Configure Registry Access
Login to your container registry
Replace <repo-endpoint> with your actual registry endpoint
docker login <repo-endpoint>

# Set environment variables for registry access
Replace placeholders with your actual values
export IMGPKG_REGISTRY_HOSTNAME_1=<repo_url>
export IMGPKG_REGISTRY_USERNAME_1=<username>
export IMGPKG_REGISTRY_PASSWORD_1=<password>

## Step 5: Copy Packages to Local Registry
Copy the downloaded Tanzu packages to your local registry
Replace <path-to-tarball> and <project-name> with your actual values
imgpkg copy --tar /<path-to-tarball>/tanzu-packages.tar --to-repo $IMGPKG_REGISTRY_HOSTNAME_1/<project-name>/packages/standard/repo

## Step 6: Copy TKG Service to Local Registry
Copy the TKG service package to your local registry
Replace harbor.example.com with your actual registry endpoint
imgpkg copy --tar tkg-service-v3.1.0.tar --to-repo harbor.example.com/tkgs/tkg-service --cosign-signatures --registry-ca-cert-path ca.crt
