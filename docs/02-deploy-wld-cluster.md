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
