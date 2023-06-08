cluster_name=$1
rg_name=$2


# Create Arc Enabled K8s
echo "Begin Deploying Arc Enabled K8s ..."
bash scripts/create-arc-enabled-k8s.sh $cluster_name $rg_name
# Create Service Account Credentials - TODO: replace with Azure RBAC
echo "Begin Creating Service Account Credentials ..."
bash scripts/create-k8s-service-account.sh
echo "Service Account Credential available in tmp directory. Use this to access the cluster remotely, e.g. from Azure Portal"
# Deploy Azure Monitor Container Insights Extension
echo "Begin Deploying Azure Monitor Container Insights Extension ..."
bash scripts/azure-monitor-container-insights/deploy-arc-enabled-k8s-extensions.sh $cluster_name $rg_name


