cluster_name=$1
rg_name=$2

# Install AZ CLI extensions if not already installed
az extension add --name connectedk8s
az extension add --name k8s-extension

# Update AZ CLI extensions
az extension update --name connectedk8s
az extension update --name k8s-extension

# Create extension instance for Azure Monitor Container Insights
echo "Creating extension instance for Azure Monitor Container Insights ..."
az k8s-extension create --name azuremonitor-containers \
                        --extension-type Microsoft.AzureMonitor.Containers \
                        --scope cluster \
                        --cluster-name $cluster_name \
                        --resource-group $rg_name \
                        --cluster-type connectedClusters

# Show extension details for Azure Monitor Container Insights
echo "Showing extension details for Azure Monitor Container Insights ..."
az k8s-extension show --name azuremonitor-containers \
                      --cluster-name $cluster_name \
                      --resource-group $rg_name \
                      --cluster-type connectedClusters

# List all extensions installed on the cluster
echo "Listing all extensions installed on the cluster ..."
az k8s-extension list --cluster-name $cluster_name \
                      --resource-group $rg_name \
                      --cluster-type connectedClusters

