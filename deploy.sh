cluster_name=$1
rg_name=$2
subscription_id=$3
tenant_id=$4

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

# Deploy Extensions
# echo "Begin Deploying Azure Monitor Container Insights Extension ..."
# bash scripts/azure-monitor-container-insights/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

#Note: Extension type microsoft.web.appservice is not registered in region eastus2. Extension is available in eastus2euap,eastus,westeurope,westcentralus. Please try to install in these regions.
# echo "Begin Deploying Azure App Service Container Insights Extension ..."
# bash scripts/app-service-extension/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

# echo "Begin Deploying Azure Machine Learning Extension ..."
# bash scripts/azure-ml-extension/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

echo "Begin Deploying Azure Policy Extension ..."
bash scripts/azure-policy-extension/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

# echo "Begin Deploying Open Service Mesh Extension ..."
# bash scripts/open-service-mesh-extension/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

# Set up RBAC Feature
echo "Begin running prereqs for Azure RBAC Feature Enablement ..."
bash scripts/grant-rbac-to-arc-enabled-k8s.sh $cluster_name $rg_name $subscription_id $tenant_id

# echo "Begin Deploying Azure RBAC Feature ..."
# bash scripts/rbac-feature/deploy-arc-enabled-k8s-feature.sh $cluster_name $rg_name
