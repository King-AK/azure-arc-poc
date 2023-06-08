cluster_name=$1
rg_name=$2

# Install AZ CLI extensions if not already installed
az extension add --name connectedk8s
az extension add --name k8s-extension

# Update AZ CLI extensions
az extension update --name connectedk8s
az extension update --name k8s-extension

# Delete extension instance for Azure Monitor Container Insights
echo "Deleting extension instance for Azure Monitor Container Insights ..."
az k8s-extension delete --name azuremonitor-containers \
                        --cluster-name $cluster_name \
                        --resource-group $rg_name \
                        --cluster-type connectedClusters