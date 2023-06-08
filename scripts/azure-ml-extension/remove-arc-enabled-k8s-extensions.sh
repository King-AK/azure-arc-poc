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

# Delete extension instance
echo "Deleting extension instance for ${extension_desc} ..."
az k8s-extension delete --name $extension_name \
                        --cluster-name $cluster_name \
                        --resource-group $rg_name \
                        --cluster-type connectedClusters