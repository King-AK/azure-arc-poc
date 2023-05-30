# azure-arc-poc
POC for Azure Arc

Log into az cli if not already logged in

```bash
az login
```

Get the latest version of connectedk8s Azure CLI extension, installed by running the following command:

```bash
az extension add --name connectedk8s
```

Register providers for Arc Enabled K8s
```bash
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation
```

Monitor registration process, may take up to 10 mins:
```bash
az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table
```

Create test RG for AzureArc
```bash
az group create --name AzureArcTest --location EastUS --output table
```

Connect existing K8s cluster to Azure Arc
```bash
az connectedk8s connect --name AzureArcTest1 --resource-group AzureArcTest
```

View Arc Agents for K8s, verify all pods in a running state:
```bash
kubectl get deployments,pods -n azure-arc
```

Delete Arc Enabled K8s resource, config resources, and any agents running on the cluster via AZ CLI:
```bash
az connectedk8s delete --name AzureArcTest1 --resource-group AzureArcTest
```

NOTE: Deleting the Azure Arc-enabled Kubernetes resource using the Azure portal removes any associated configuration resources, but does not remove any agents running on the cluster. Best practice is to delete the Azure Arc-enabled Kubernetes resource using az connectedk8s delete rather than deleting the resource in the Azure portal.
