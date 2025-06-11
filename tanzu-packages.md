# Run on windows/linux connected to the internet

Install Tanzu CLI:
https://github.com/vmware-tanzu/tanzu-cli/releases

tanzu plugin install --group vmware-vsphere/default:v8.0.3

tanzu imgpkg tag list -i projects.registry.vmware.com/tkg/packages/standard/repo

tanzu imgpkg copy -b projects.registry.vmware.com/tkg/packages/standard/repo:v2025.4.29 --to-tar ./tanzu-packages-v2025.4.29.tar


tanzu plugin download-bundle --group vmware-tkg/default:v2.5.2 --to-tar plugin-bundle-tkg.tar.gz
---

# Run on Admin VM

tanzu plugin source update default --uri registry.example.com/tanzu/plugin-inventory:latest

imgpkg copy -b projects.packages.broadcom.com/vsphere/iaas/tkg-service/3.1.0/tkg-service:3.1.0 --to-tar tkg-service-v3.1.0.tar --cosign-signatures



sudo cp harbor-ova.crt /usr/local/share/ca-certificates 
sudo update-ca-certificates
systemctl reload docker
systemctl restart docker

docker login <repo-endpoint>
export IMGPKG_REGISTRY_HOSTNAME_1=<repo_url>
export IMGPKG_REGISTRY_USERNAME_1=<username>
export IMGPKG_REGISTRY_PASSWORD_1=<password>

##Command to copy the binaries to local Image repositort
imgpkg copy --tar /<path-to-tarball>/tanzu-packages.tar --to-repo $IMGPKG_REGISTRY_HOSTNAME_1/<project-name>/packages/standard/repo




imgpkg copy --tar tkg-service-v3.1.0.tar --to-repo harbor.example.com/tkgs/tkg-service --cosign-signatures --registry-ca-cert-path ca.crt
