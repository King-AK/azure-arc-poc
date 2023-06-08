cluster_name=$1
rg_name=$2

# Remove Extensions
echo "Begin Removing Azure Monitor Container Insights Extension ..."
bash scripts/azure-monitor-container-insights/remove-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

echo "Begin Removing Azure Policy Extension ..."
bash scripts/azure-policy-extension/remove-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

echo "Begin Removing Azure Machine Learning Extension ..."
bash scripts/azure-ml-extension/remove-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

echo "Begin Removing Azure App Service Extension ..."
bash scripts/app-service-extension/remove-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

echo "Begin Removing Open Service Mesh Extension ..."
bash scripts/open-service-mesh-extension/remove-arc-enabled-k8s-extensions.sh $cluster_name $rg_name

# Delete Service Account Credentials - TODO: replace with Azure RBAC
echo "Begin Deleting Service Account Credentials ..."
bash scripts/delete-k8s-service-account.sh
# Delete Arc Enabled K8s
echo "Begin Deleting Arc Enabled K8s ..."
bash scripts/delete-arc-enabled-k8s.sh $cluster_name $rg_name

echo "Remember to go to the portal and delete extra resources provisioned by Azure, e.g. RGs and log analytics workspaces!!!"