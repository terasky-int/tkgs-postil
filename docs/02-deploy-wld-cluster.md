# Deploy Workload Cluster

> **Note**: If the Organization CA certificate is not installed on your machine, you have two options:
> 1. Add the `--insecure-skip-tls-verify` flag to the login command (not recommended for production)
> 2. Install the vSphere CA certificate on your machine (recommended for production)

Login to the `namespace` with that command: 
```bash
kubectl vsphere login --server=172.18.29.12 --tanzu-kubernetes-cluster-namespace test-ns --vsphere-username=administrator@vsphere.local
```

---

Switch your kubectl context to the namespace.

```bash
kubectl config use-context dev-ns
```

---

Before deploying a workload cluster, you need to configure several variables in the workload cluster YAML file. To get the available values for these configurations, run the following commands:

- Check available VM classes that can be used for control plane and worker nodes:
- List available Tanzu Kubernetes releases (TKr) versions:
- View available storage classes for persistent volumes:


```bash
kubectl get virtualmachineclasses
kubectl get tkr
kubectl get sc
```


---

To pull images from a private Harbor registry, you need to add the Harbor CA certificate to the nodes. This requires the CA certificate to be double base64 encoded.

1. Get your Harbor CA certificate in .crt format

2. Double base64 encode the certificate:

```bash
cat ca.crt | base64 | tr -d "\n" | base64 | tr -d "\n"
```

```bash
cp wld-cluster-template.yaml <WLD-CLUSTER-NAME>.yaml
```

- Update Namespace name for the secret and for the cluster
- Update Cluster name
- Update the name and the value of the `additional-ca-1` in the `Secret` `<WLD-CLUSTER-NAME>-user-trusted-ca-secret`.
- Update the Storage class
- Update VM Classes
- Update Network settings (pods and services CIDR)
- Update TKR version




Once you have filled out the required information, you can apply the manifest to deploy the cluster.

```bash
kubectl apply -f <WLD-CLUSTER-NAME>.yaml
```