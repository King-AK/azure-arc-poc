cluster_name=$1
rg_name=$2

# Connect existing K8s cluster to Azure Arc
az connectedk8s connect --name $cluster_name \
                        --resource-group $rg_name

# View Arc Agents for K8s
kubectl get deployments,pods -n azure-arc
