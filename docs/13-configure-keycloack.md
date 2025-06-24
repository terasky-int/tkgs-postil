# Configure Keycloak after OpenLegacy installation

This document provides step-by-step instructions for configuring Keycloak authentication settings after the OpenLegacy application has been deployed and exposed.

## Prerequisites

- OpenLegacy application deployed and running
- Keycloak service accessible via FQDN
- DNS records configured for Keycloak
- Web browser with access to the Keycloak admin interface

## Step 1: Access Keycloak admin interface

Open your web browser and navigate to the Keycloak admin interface:

```
https://<keycloak-fqdn>/auth/
```

Replace `<keycloak-fqdn>` with your actual Keycloak FQDN (e.g., `hub-enterprise-keycloak-k8s.ipa-bs.org`).

## Step 2: Navigate to your client

### Select your realm

1. From the realm dropdown in the top-left corner, select your realm
2. The realm name is typically the same as your OpenLegacy deployment

### Access clients section

1. In the left sidebar, click on **Clients**
2. This will display all configured clients in your realm

## Step 3: Configure the hub-spa client

### Find the hub-spa client

1. In the clients list, find and click on the client ID **hub-spa**
2. This client is used by the OpenLegacy Hub application for authentication

### Update redirect URIs

1. In the client configuration page, locate the **Valid Redirect URIs** field
2. Update the redirect URI with the following changes:

#### Required changes:

1. **Use HTTP instead of HTTPS**:
   - Change from: `https://hub-enterprise-k8s.ipa-bs.org/*`
   - Change to: `http://hub-enterprise-k8s.ipa-bs.org/*`

2. **Use the correct FQDN**:
   - Ensure the FQDN matches your actual hub-enterprise application URL
   - Example: `http://hub-enterprise-k8s.ipa-bs.org/*`

#### Example configuration:

```
Valid Redirect URIs:
http://hub-enterprise-k8s.ipa-bs.org/*
```

### Save the configuration

1. Click **Save** to apply the changes
2. Verify that the changes have been applied successfully

## Step 4: Verify client configuration

### Check client settings

1. Verify the following settings are correct:
   - **Client ID**: `hub-spa`
   - **Client Protocol**: `openid-connect`
   - **Access Type**: `public`
   - **Valid Redirect URIs**: `http://hub-enterprise-k8s.ipa-bs.org/*`

### Test the configuration

1. Navigate to your OpenLegacy Hub application
2. Attempt to log in using the configured authentication
3. Verify that the redirect works correctly after authentication

