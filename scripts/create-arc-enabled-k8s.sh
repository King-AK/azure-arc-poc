cluster_name=$1
rg_name=$2

# Add extensions and providers if not already configured
az extension add --upgrade --yes --name connectedk8s
az extension add --upgrade --yes --name k8s-extension
az extension add --upgrade --yes --name customlocation
az provider register --namespace Microsoft.ExtendedLocation --wait
az provider register --namespace Microsoft.Web --wait
az provider register --namespace Microsoft.KubernetesConfiguration --wait
az extension remove --name appservice-kube
az extension add --upgrade --yes --name appservice-kube

# Connect existing K8s cluster to Azure Arc
az connectedk8s connect --name $cluster_name \
                        --resource-group $rg_name

# View Arc Agents for K8s
kubectl get deployments,pods -n azure-arc
