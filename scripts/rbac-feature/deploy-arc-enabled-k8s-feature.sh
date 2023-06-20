cluster_name=$1
rg_name=$2
extension_name="az-policy-ext" # Name of the extension
extension_type="Microsoft.PolicyInsights" # Type of the extension
extension_desc="Azure Policy"

rbac_config_file_path="tmp/rbac-setup-config.json"

# Install AZ CLI extensions if not already installed
az extension add --name connectedk8s
az extension add --name k8s-extension

# Update AZ CLI extensions
az extension update --name connectedk8s
az extension update --name k8s-extension

# Enable feature
server_app_id=$(jq -r .serverAppID $rbac_config_file_path)
server_app_secret=$(jq -r .serverAppSecret $rbac_config_file_path)
echo "Creating extension instance for ${extension_desc} ..."
az connectedk8s enable-features --cluster-name $cluster_name \
                                --resource-group $rg_name \
                                --features azure-rbac \
                                --app-id "${server_app_id}" \
                                --app-secret "${server_app_secret}"

# Try Cluster API steps from docs
# Copy the guard secret that contains authentication and authorization webhook configuration files
kubectl get secret azure-arc-guard-manifests -n kube-system \
                                             -o yaml > tmp/azure-arc-guard-manifests.yaml
