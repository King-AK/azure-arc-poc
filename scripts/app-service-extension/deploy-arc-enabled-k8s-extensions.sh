cluster_name=$1
rg_name=$2

extension_name="appservice-ext" # Name of the extension
extension_type="Microsoft.Web.Appservice" # Type of the extension
extension_desc="App Service"

namespace="appservice-ns" # Namespace in your cluster to install the extension and provision resources
custom_location_name="my-custom-location" # Name of the custom location
storage_class_name="hostpath"

# Install AZ CLI extensions if not already installed
az extension add --name connectedk8s
az extension add --name k8s-extension

# Update AZ CLI extensions
az extension update --name connectedk8s
az extension update --name k8s-extension

# Create extension instance
echo "Creating extension instance for ${extension_desc} ..."
az k8s-extension create \
    --resource-group $rg_name \
    --name $extension_name \
    --cluster-type connectedClusters \
    --cluster-name $cluster_name \
    --extension-type $extension_type \
    --release-train stable \
    --auto-upgrade-minor-version true \
    --scope cluster \
    --release-namespace $namespace \
    --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" \
    --configuration-settings "appsNamespace=${namespace}" \
    --configuration-settings "clusterName=${cluster_name}" \
    --configuration-settings "keda.enabled=false" \
    --configuration-settings "buildService.storageClassName=${storage_class_name}" \
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
    --configuration-settings "customConfigMap=${namespace}/kube-environment-config" \
    # --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${rg_name}"

# Show extension details
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

# # Create custom location
# echo "Creating custom location for Arc Enabled K8s ..."
# app_service_extension_id=$(az k8s-extension show \
#     --cluster-type connectedClusters \
#     --cluster-name $cluster_name \
#     --resource-group $rg_name \
#     --name $extension_name \
#     --query id \
#     --output tsv)

# connected_cluster_id=$(az connectedk8s show --resource-group $rg_name \
#                                             --name $cluster_name-query id \
#                                             --output tsv)

# az customlocation create \
#     --resource-group $rg_name \
#     --name $custom_location_name \
#     --host-resource-id $connected_cluster_id \
#     --namespace $namespace \
#     --cluster-extension-ids $app_service_extension_id

# echo "Showing custom location information ..."
# az customlocation show --resource-group $rg_name \
#                        --name $custom_location_name

# custom_location_id=$(az customlocation show \
#     --resource-group $rg_name \
#     --name $custom_location_name \
#     --query id \
#     --output tsv)

# # Create App Service K8s environment
# echo "Creating App Service K8s environment ..."
# az appservice kube create \
#     --resource-group $rg_name \
#     --name $cluster_name \
#     --custom-location $custom_location_id

# echo "Showing App Service k8s environment provisioningState ..."
# az appservice kube show --resource-group $rg_name \
#                         --name $cluster_name