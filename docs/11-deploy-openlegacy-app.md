# Deploy OpenLegacy application

This document provides step-by-step instructions for deploying the OpenLegacy application in a Kubernetes environment using the provided installation files.

## Prerequisites

- Kubernetes cluster with kubectl access
- OpenLegacy installation files located in `/home/k8s/openlegacy`
- Harbor registry access configured
- PostgreSQL database available
- Ingress controller configured (Contour recommended)

## Step 1: Create backup of installation files

Before making any changes, create a backup of the original installation files:

```bash
sudo cp -r /opt/openlegacy/ /opt/openlegacy.org
```

This backup ensures you can restore the original files if needed during troubleshooting.

## Step 2: Copy installation files to target directory

Copy all files from the source directory to the target installation directory:

```bash
cp -r /home/k8s/openlegacy/* /opt/openlegacy/
```

## Step 3: Modify the installer script

Edit the `installer-helm.sh` file to add the required modifications:

```bash
# Navigate to the installation directory
cd /opt/openlegacy


# Edit the installer script
vi installer-helm.sh
```

### Locate the prepare_installation() function

Find the `prepare_installation()` function (around line 554) and add the following lines after the `generate_secrets` line:

```bash
prepare_installation() {
    log "INFO" "Preparing installation files..."

    # Extract Helm charts
    tar -xf "$HELM_CHARTS_ARCHIVE" --strip-components=3 -C "$BASE_PATH"

    # Generate certificates and secrets
    generate_certificates
    generate_secrets
    
    # Add these lines after generate_secrets
    sed -i 's|postgres:13|harbor-01.ipa-bs.org/openlegacy/postgres:13|g' $HELM_VALUES_FILE_TEMPLATE
    cp /opt/openlegacy/helm-charts/hub-enterprise/templates/hub-enterprise/deployment.yaml.org /opt/openlegacy/helm-charts/hub-enterprise/templates/hub-enterprise/deployment.yaml
    sed -i '/podSecurityContext.*nindent/a\
        fsGroup: 1000' /opt/openlegacy/helm-charts/hub-enterprise/templates/hub-enterprise/deployment.yaml
}
```

## Step 4: Verify and update configuration

Check the current configuration in `installer-helm.conf`:

```bash
cat installer-helm.conf
```

### Expected configuration

The configuration should match the following values. Update any incorrect values:

```bash
# OpenLegacy Hub Configuration
# Generated on 2025-05-29 13:29:51

# Images Configuration
KEYCLOAK_IMAGE='harbor-01.ipa-bs.org/openlegacy/openlegacy-keycloak:22.0.5'
HUB_ENT_DB_MIGR_IMAGE='harbor-01.ipa-bs.org/openlegacy/hub-enterprise-db-migration:3.0.9.1'
HUB_ENT_IMAGE='harbor-01.ipa-bs.org/openlegacy/hub-enterprise:3.0.9.1'

# Registry Configuration
REGISTRY_URL='harbor-01.ipa-bs.org'

# URLs Configuration
OL_HUB_URL='https://hub-enterprise-k8s.ipa-bs.org'
OL_KEYCLOAK_URL='https://hub-enterprise-keycloak-k8s.ipa-bs.org'

# Kubernetes Configuration
K8S_DISTRIBUTION='k8s'
k8s_namespace='hub-enterprise'
#INGRESS_TYPE='contour'

# Database Configuration
OL_DB_HOST='hub-enterprise-postgres'
OL_DB_PORT='5432'
OL_DB_NAME='postgres'
OL_DB_USER='postgres'
OL_DB_PASSWORD='postgres'

# Monitoring Configuration
MONITORING='false'
OL_SCREEN_PORT='1512'
```

## Step 5: Run the installation

Execute the installer script from the correct directory:

### Create namespace and configure security

Create the namespace and configure pod security:

```bash
kubectl create ns hub-enterprise
kubectl label --overwrite ns hub-enterprise pod-security.kubernetes.io/enforce=privileged
```

```bash
# Navigate to the installation directory
cd /opt/openlegacy

# Make the script executable if needed
chmod +x installer-helm.sh

# Run the installation
./installer-helm.sh
```
