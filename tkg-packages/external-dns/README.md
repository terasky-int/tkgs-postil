# Deploy External DNS

## Microsoft DNS

### Secure Updates Using RFC3645 (GSS-TSIG)

Prerequisites:

- Create a DNS zone
- Enable secure dynamic updates for the zone
- Enable Zone Transfers to all servers

## Deploy the External DNS Package

Set the context of kubectl to the relevant cluster. For example:

```bash
kubectx mob-wlc-dev
```

Retrieve the version of the ExternalDNS package.

```bash
PKG_NAME=external-dns.tanzu.vmware.com
PKG_VERSIONS=($(tanzu package available list "$PKG_NAME" -n tkg-system -o json | jq -r ".[].version" | sort -t "." -k1,1n -k2,2n -k3,3n))
PKG_VERSION=${PKG_VERSIONS[-1]}
echo "$PKG_VERSION"
```

For example: `0.12.2+vmware.7-tkg.1`

Install the package.

```bash
tanzu package install external-dns \
--package "external-dns.tanzu.vmware.com" \
--version "0.12.2+vmware.7-tkg.1" \
--values-file external-dns-data-values.yaml \
# --ytt-overlay-file overlay-external-dns-kerberos.yaml \
--namespace tkg-packages
```

Output:

```text
| Installing package 'external-dns.tanzu.vmware.com'
| Getting namespace 'tkg-packages'
| Getting package metadata for 'external-dns.tanzu.vmware.com'
| Creating service account 'external-dns-tkg-packages-sa'
| Creating cluster admin role 'external-dns-tkg-packages-cluster-role'
| Creating cluster role binding 'external-dns-tkg-packages-cluster-rolebinding'
| Creating secret 'external-dns-tkg-packages-values'
| Creating package resource
| Package install status: Reconciling

```

Confirm that the `external-dns` pod is running.

```bash
kubectl get pods -n tanzu-system-service-discovery
```

Output:

```text
NAME                            READY   STATUS    RESTARTS   AGE
external-dns-7885494fc6-v8hw6   1/1     Running   0          30s
```

You can also view the External DNS logs.

```bash
kubectl logs $(kubectl get pod -n tanzu-system-service-discovery -o name) -n tanzu-system-service-discovery
```

For example:

```text
time="2021-11-29T12:22:36Z" level=info msg="Instantiating new Kubernetes client"
time="2021-11-29T12:22:36Z" level=info msg="Using inCluster-config based on serviceaccount-token"
time="2021-11-29T12:22:36Z" level=info msg="Created Kubernetes client https://100.64.0.1:443"
time="2021-11-29T12:22:38Z" level=info msg="Created Dynamic Kubernetes client https://100.64.0.1:443"
time="2021-11-29T12:22:39Z" level=info msg="Configured RFC2136 with zone 'terasky.demo.' and nameserver 'demo-dc-01.terasky.demo:53'"
```

Reference:

- [Implement Service Discovery with ExternalDNS](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-packages-external-dns.html)
- [External DNS - Secure Updates Using RFC3645 (GSS-TSIG)](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/rfc2136.md#secure-updates-using-rfc3645-gss-tsig)
- [Using External DNS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/rfc2136.md#using-external-dns)
- [Sample krb5.conf File - web.mit.edu](https://web.mit.edu/kerberos/krb5-1.12/doc/admin/conf_files/krb5_conf.html#sample-krb5-conf-file)
