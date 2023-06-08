cluster_name=$1
rg_name=$2
extension_name="test-azml-instance" # Name of the extension
extension_type="Microsoft.AzureML.Kubernetes" # Type of the extension
extension_desc="Azure Machine Learning"

# Install AZ CLI extensions if not already installed
az extension add --name connectedk8s
az extension add --name k8s-extension

# Update AZ CLI extensions
az extension update --name connectedk8s
az extension update --name k8s-extension

# Create extension instance
echo "Creating extension instance for ${extension_desc} ..."
az k8s-extension create --cluster-name $cluster_name \
                        --resource-group $rg_name \
                        --cluster-type connectedClusters \
                        --extension-type $extension_type \
                        --scope cluster \
                        --name $extension_name \
                        --config enableTraining=True

# Show extension details for AZML
echo "Showing extension details for ${extension_desc} ..."
az k8s-extension show --name $extension_name \
                      --cluster-name $cluster_name \
                      --resource-group $rg_name \
                      --cluster-type connectedClusters

# List all extensions installed on the cluster
echo "Listing all extensions installed on the cluster ..."
az k8s-extension list --cluster-name $cluster_name \
                      --resource-group $rg_name \
                      --cluster-type connectedClusters
