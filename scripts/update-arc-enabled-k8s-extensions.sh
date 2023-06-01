cluster_name=$1
rg_name=$2

# Install AZ CLI extensions if not already installed
az extension add --name connectedk8s
az extension add --name k8s-extension

# Update AZ CLI extensions
az extension update --name connectedk8s
az extension update --name k8s-extension

# Update extension instance for Azure Monitor Container Insights
# NOTE: setting auto-upgrade-minor-version to "true" the extension will automatically be upgraded when a new minor version is released
echo "Updating extension instance for Azure Monitor Container Insights ..."
az k8s-extension update --name azuremonitor-containers \
                        --cluster-name $cluster_name \
                        --resource-group $rg_name \
                        --auto-upgrade-minor-version true \
                        --cluster-type connectedClusters

# NOTE: Manual upgrades are required to get a new major instance of an extension. You choose when to upgrade in order to avoid any unexpected breaking changes with major version upgrades.
#e.g.  `az k8s-extension update --cluster-name <clusterName> --resource-group <resourceGroupName> --cluster-type connectedClusters --name azureml --version x.y.z`