# Deploy cert-manager

Set the context of kubectl to the relevant cluster. For example:

```bash
kubectx mob-wlc-dev
```

```bash
PKG_NAME=cert-manager.tanzu.vmware.com
PKG_VERSIONS=($(tanzu package available list "$PKG_NAME" -n tkg-system -o json | jq -r ".[].version" | sort -t "." -k1,1n -k2,2n -k3,3n))
PKG_VERSION=${PKG_VERSIONS[-1]}
echo "$PKG_VERSION"
```

For example: `1.12.2+vmware.2-tkg.2`

Install the package.

```bash
kubectl create namespace tkg-packages
```

```bash
tanzu package install cert-manager \
--package "$PKG_NAME" \
--version "$PKG_VERSION" \
--namespace tkg-packages 
```

Output:

```text
| Installing package 'cert-manager.tanzu.vmware.com'
| Getting namespace 'tkg-packages'
| Getting package metadata for 'cert-manager.tanzu.vmware.com'
| Creating service account 'cert-manager-tkg-packages-sa'
| Creating cluster admin role 'cert-manager-tkg-packages-cluster-role'
| Creating cluster role binding 'cert-manager-tkg-packages-cluster-rolebinding'
| Creating package resource
| Package install status: Reconciling

 Added installed package 'cert-manager' in namespace 'tkg-packages'
```

Confirm that the `cert-manager` package has been installed.

```bash
tanzu package installed list -n tkg-packages
```

Output:

```text
| Retrieving installed packages...
  NAME          PACKAGE-NAME                   PACKAGE-VERSION        STATUS
  cert-manager  cert-manager.tanzu.vmware.com  1.1.0+vmware.1-tkg.2   Reconcile succeeded
```

Confirm that the `cert-manager` pods are running.

```bash
kubectl get pods -n cert-manager
```

Output:

```text
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5b7d865479-nmc4k              1/1     Running   0          6m18s
cert-manager-cainjector-5b89ff9487-95smr   1/1     Running   0          6m18s
cert-manager-webhook-7c866b85c-rtqrn       1/1     Running   0          6m18s
```

Reference:

- [Installing Cert Manager](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-packages-cert-manager.html)
