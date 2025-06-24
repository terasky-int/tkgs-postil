# Expose OpenLegacy application

This document provides instructions for exposing the OpenLegacy application and Keycloak service using Contour HTTPProxy and configuring DNS records for external access.

## Prerequisites

- OpenLegacy application deployed and running in Kubernetes
- Contour ingress controller installed and configured
- Access to DNS management for your domain
- kubectl configured with cluster access

## Step 1: Edit HTTPProxy configuration files

### Edit hub-httpproxy.yaml

Navigate to the OpenLegacy configuration directory and edit the hub HTTPProxy file:

```bash
cd /opt/openlegacy
vi hub-httpproxy.yaml
```

Update the FQDN in the file to match your domain. The file should look similar to this:

```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: hub-enterprise-proxy
  namespace: hub-enterprise
spec:
  virtualhost:
    fqdn: hub-enterprise-k8s.ipa-bs.org  # Change this to your domain
    tls:
      secretName: hub-enterprise-tls
  routes:
  - conditions:
    - prefix: /
    services:
    - name: hub-enterprise
      port: 8080
```

### Edit keycloak-httpproxy.yaml

Edit the Keycloak HTTPProxy configuration:

```bash
vi keycloak-httpproxy.yaml
```

Update the FQDN in the file to match your domain:

```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: keycloak-proxy
  namespace: hub-enterprise
spec:
  virtualhost:
    fqdn: hub-enterprise-keycloak-k8s.ipa-bs.org  # Change this to your domain
    tls:
      secretName: keycloak-tls
  routes:
  - conditions:
    - prefix: /
    services:
    - name: openlegacy-keycloak
      port: 8080
```

## Step 2: Apply HTTPProxy configurations

Apply the HTTPProxy configurations to your cluster:

```bash
# Apply hub HTTPProxy
kubectl apply -f hub-httpproxy.yaml

# Apply Keycloak HTTPProxy
kubectl apply -f keycloak-httpproxy.yaml
```

## Step 3: Verify HTTPProxy status

Check that the HTTPProxy resources are properly configured:

```bash
# Check HTTPProxy status
kubectl get httpproxy -n hub-enterprise

# Check for any errors
kubectl describe httpproxy hub-enterprise-proxy -n hub-enterprise
kubectl describe httpproxy keycloak-proxy -n hub-enterprise
```

## Step 4: Get Contour LoadBalancer external IP

Retrieve the external IP address of the Contour LoadBalancer service:

```bash
kubectl get svc -n vmware-tanzu-ingress envoy
```

Look for the `EXTERNAL-IP` column in the output. The IP address will be used for DNS configuration.

Example output:
```
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
envoy   LoadBalancer   10.96.123.45     203.0.113.10     80:30080/TCP,443:30443/TCP   2d
```

## Step 5: Configure DNS records

Create DNS A records pointing to the Contour LoadBalancer external IP:

### For the hub application

Create an A record with:
- **Name**: `hub-enterprise-k8s` (or your chosen subdomain)
- **Type**: A
- **Value**: [Contour LoadBalancer external IP]
- **TTL**: 300 (or your preferred TTL)

### For Keycloak

Create an A record with:
- **Name**: `hub-enterprise-keycloak-k8s` (or your chosen subdomain)
- **Type**: A
- **Value**: [Contour LoadBalancer external IP]
- **TTL**: 300 (or your preferred TTL)

