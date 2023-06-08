cluster_name=$1
rg_name=$2


# Create Arc Enabled K8s
echo "Begin Deploying Arc Enabled K8s ..."
bash scripts/create-arc-enabled-k8s.sh $cluster_name $rg_name
# Create Service Account Credentials - TODO: replace with Azure RBAC
echo "Begin Creating Service Account Credentials ..."
bash scripts/create-k8s-service-account.sh
echo "Service Account Credential available in tmp directory. Use this to access the cluster remotely, e.g. from Azure Portal"
# Create custom location
echo "Begin Enable Custom Location ..."
bash scripts/enable-arc-custom-location.sh $cluster_name $rg_name
# Deploy Azure Monitor Container Insights Extension
echo "Begin Deploying Azure Monitor Container Insights Extension ..."
bash scripts/azure-monitor-container-insights/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name
# # Deploy Azure App Service Extension
# # Note: Extension type microsoft.web.appservice is not registered in region eastus2. Extension is available in eastus2euap,eastus,westeurope,westcentralus. Please try to install in these regions.
# echo "Begin Deploying Azure App Service Extension ..."
# bash scripts/app-service-extension/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

