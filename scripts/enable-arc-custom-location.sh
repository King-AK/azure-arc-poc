cluster_name=$1
rg_name=$2

# Add extensions and providers if not already configured
az extension add --upgrade --yes --name connectedk8s
az extension add --upgrade --yes --name k8s-extension
az extension add --upgrade --yes --name customlocation
az provider register --namespace Microsoft.ExtendedLocation --wait

# Enable custom locations feature on cluster
az connectedk8s enable-features --name $cluster_name \
                        --resource-group $rg_name \
                        --features cluster-connect custom-locations
