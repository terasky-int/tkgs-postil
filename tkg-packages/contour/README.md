# Deploy Contour

Set the context of kubectl to the relevant cluster. For example:

```bash
kubectx mob-wlc-dev
```

Retrieve the version of the available package.

```bash
PKG_NAME=contour.tanzu.vmware.com
PKG_VERSIONS=($(tanzu package available list "$PKG_NAME" -n tkg-system -o json | jq -r ".[].version" | sort -t "." -k1,1n -k2,2n -k3,3n))
PKG_VERSION=${PKG_VERSIONS[-1]}
echo "$PKG_VERSION"
```

For example: `1.28.2+vmware.1-tkg.1`

Install the package.

```bash
tanzu package install contour \
--package "$PKG_NAME" \
--version "$PKG_VERSION" \
--values-file contour-data-values.yaml \
--namespace tkg-packages
```

Output:

```text
| Installing package 'contour.tanzu.vmware.com'
| Getting namespace 'tkg-packages'
| Getting package metadata for 'contour.tanzu.vmware.com'
| Creating service account 'contour-tkg-packages-sa'
| Creating cluster admin role 'contour-tkg-packages-cluster-role'
| Creating cluster role binding 'contour-tkg-packages-cluster-rolebinding'
| Creating secret 'contour-tkg-packages-values'
| Creating package resource
| Package install status: Reconciling

 Added installed package 'contour' in namespace 'tkg-packages'
```

Confirm that the `contour` package has been installed.

```bash
tanzu package installed list -n tkg-packages
```

Output:

```text
| Retrieving installed packages...
  NAME          PACKAGE-NAME                   PACKAGE-VERSION        STATUS               
  cert-manager  cert-manager.tanzu.vmware.com  1.11.1+vmware.1-tkg.1  Reconcile succeeded  
  contour       contour.tanzu.vmware.com       1.24.5+vmware.1-tkg.1  Reconcile succeeded 
```

Confirm that the `contour` pods are running.

```bash
kubectl get pods -n tanzu-system-ingress
```

Output:

```text
NAME                       READY   STATUS    RESTARTS   AGE
contour-854fd57d58-lbt8j   1/1     Running   0          16m
contour-854fd57d58-vl8xk   1/1     Running   0          16m
envoy-mkg26                2/2     Running   0          16m
```

Reference:

- [Implementing Ingress Control with Contour](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-packages-ingress-contour.html)
