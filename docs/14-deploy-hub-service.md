# Deploy hub service

This document provides step-by-step instructions for deploying the OpenLegacy hub service using the provided Kubernetes YAML files.

## Prerequisites

- Kubernetes cluster with kubectl access
- Contour ingress controller installed
- Harbor registry access configured
- Access to DNS management for your domain

## Step 1: Prepare the deployment files

### Download and organize files

Copy all YAML files to your working directory:

```bash
# Create a working directory
mkdir hub-service-deployment
cd hub-service-deployment

# Copy all YAML files to this directory
cp /path/to/openlegacy-service-k8s/*.yaml .
```

### Verify file structure

Ensure you have the following files:
- `namespace.yaml` - Namespace definition
- `deployment.yaml` - Application deployment
- `service.yaml` - Service configuration
- `pvc.yaml` - Persistent volume claim
- `httpproxy.yaml` - Contour HTTPProxy configuration
- `poc-secret.yaml` - Application secrets

## Step 2: Edit configuration files

### Edit namespace.yaml

Update the namespace name and labels as needed:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: openlegacy-service  # Change if needed
    pod-security.kubernetes.io/enforce: privileged
  name: openlegacy-service  # Change if needed
spec:
  finalizers:
  - kubernetes
```

**Important**: If you change the namespace name, update it in all other YAML files.

### Edit httpproxy.yaml

Update the FQDN and service names:

```yaml
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: hub-service-1  # Change if needed
  namespace: openlegacy-service  # Must match namespace.yaml
spec:
  routes:
  - conditions:
    - prefix: /
    services:
    - name: hub-service-1  # Must match service name
      port: 80
  virtualhost:
    fqdn: hub-service-1.ipa-bs.org  # Change to your domain
```

**Required changes**:
- Update `fqdn` to match your domain
- Ensure `namespace` matches the namespace in `namespace.yaml`
- Update service name if needed

### Edit deployment.yaml

Update the deployment configuration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hub-service-1  # Change if needed
  namespace: openlegacy-service  # Must match namespace.yaml
  labels:
    app: hub-service-1  # Must match selector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hub-service-1  # Must match labels
  template:
    metadata:
      labels:
        app: hub-service-1  # Must match selector
    spec:
      containers:
      - name: hub-service-1
        image: harbor-01.ipa-bs.org/openlegacy/main-frame-rpc-spring-java-rest:3.0.9  # Update image if needed
        ports:
        - containerPort: 8080
        envFrom:
        - secretRef:
            name: hub-service-1-secrets  # Must match secret name
        volumeMounts:
        - name: metadata-volume
          mountPath: /usr/opz
      volumes:
      - name: metadata-volume
        persistentVolumeClaim:
          claimName: hub-service-1-pvc  # Must match PVC name
```

**Required changes**:
- Update `namespace` to match `namespace.yaml`
- Update image if using a different registry or version
- Ensure secret name matches `poc-secret.yaml`
- Ensure PVC name matches `pvc.yaml`

### Edit service.yaml

Update the service configuration:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hub-service-1  # Must match HTTPProxy service name
  namespace: openlegacy-service  # Must match namespace.yaml
spec:
  selector:
    app: hub-service-1  # Must match deployment labels
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

**Required changes**:
- Update `namespace` to match `namespace.yaml`
- Ensure `selector` matches deployment labels

### Edit pvc.yaml

Update the persistent volume claim:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hub-service-1-pvc  # Must match deployment PVC name
  namespace: openlegacy-service  # Must match namespace.yaml
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi  # Adjust storage size as needed
```

**Required changes**:
- Update `namespace` to match `namespace.yaml`
- Adjust storage size if needed

### Edit poc-secret.yaml

Update the secrets configuration:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: hub-service-1-secrets  # Must match deployment secret name
  namespace: openlegacy-service  # Must match namespace.yaml
type: Opaque
stringData:
  # OpenLegacy configuration secrets
  OL_FLOW_TYPE: RPC
  OL_SOURCE_PROVIDER: OL_PROJECT_ZIP
  OL_PROJECT_ZIP_PATH: /usr/opz/ol-project.opz
  OL_LICENSE_KEY: eyJhbGciOiJSUzI1NiJ9.eyJtYXN0ZXJMaWNlbnNlSWQiOiJhZDAyODQw
```

**Required changes**:
- Update `namespace` to match `namespace.yaml`
- The license key is already provided - update it if you have a different license
- Ensure the `OL_PROJECT_ZIP_PATH` points to the correct location in your container

## Step 3: Apply the configuration files

### Apply namespace first

```bash
kubectl apply -f namespace.yaml
```

### Verify namespace creation

```bash
kubectl get namespace openlegacy-service
```

### Apply PVC

```bash
kubectl apply -f pvc.yaml
```

### Deploy temporary pod and copy OPZ file

1. **Apply the temporary pod**:

```bash
kubectl apply -f temp-pod.yaml
```

2. **Wait for the pod to be ready**:

```bash
kubectl get pods -n openlegacy-service
```

3. **Copy the OPZ file to the pod**:

```bash
kubectl cp ol-project.opz temp-pod:/usr/opz/ol-project.opz -n openlegacy-service
```

4. **Verify the file was copied successfully**:

```bash
kubectl exec temp-pod -n openlegacy-service -- ls -la /usr/opz/
```

5. **Delete the temporary pod**:

```bash
kubectl delete pod temp-pod -n openlegacy-service
```

### Apply remaining files

```bash
# Apply all other files
kubectl apply -f poc-secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f httpproxy.yaml
```

### Verify deployment

```bash
# Check all resources in the namespace
kubectl get all -n openlegacy-service

# Check HTTPProxy status
kubectl get httpproxy -n openlegacy-service

# Check pod status
kubectl get pods -n openlegacy-service

# Check service status
kubectl get svc -n openlegacy-service
```

## Step 4: Configure DNS

### Get Contour LoadBalancer IP

Retrieve the external IP address of the Contour LoadBalancer service:

```bash
kubectl get svc -n tanzu-system-ingress envoy
```

Look for the `EXTERNAL-IP` column in the output.

Example output:
```
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
envoy   LoadBalancer   10.96.123.45     203.0.113.10     80:30080/TCP,443:30443/TCP   2d
```

### Create DNS record

Create an A record pointing to the Contour LoadBalancer external IP:

- **Name**: `hub-service-1` (or your chosen subdomain)
- **Type**: A
- **Value**: [Contour LoadBalancer external IP]
- **TTL**: 300 (or your preferred TTL)

