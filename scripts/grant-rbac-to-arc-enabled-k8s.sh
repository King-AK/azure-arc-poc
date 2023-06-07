cluster_name=$1
rg_name=$2
SP_NAME=$cluster_name

# Collect Object ID
OBJECT_ID=$(az ad signed-in-user show --query userPrincipalName -o tsv)

# Collect Connected K8s resource id
RESOURCE_ID=$(az connectedk8s show --name docker-desktop \
                                   --resource-group domain-a | jq -r .id)

# TODO: Add steps to create server application
# Create Server SP 
echo "Creating SP $SP_NAME ..."
OUTPUT=$(az ad sp create-for-rbac --name $SP_NAME)
APP_ID=$(echo $OUTPUT | jq -r .appId)
SP_SECRET=$(echo $OUTPUT | jq -r .password)
echo "Created SP $SP_NAME with APP ID: $APP_ID ..."

# Enable RBAC on the Arc Enabled k8s cluster
az connectedk8s enable-features --name <clusterName> \
                                --resource-group <resourceGroupName> \
                                --features azure-rbac \
                                --app-id "${SERVER_APP_ID}" \
                                --app-secret "${SERVER_APP_SECRET}"


# Create ClusterRoleBinding mapped to AD entity
# kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin \
#                                                     --user=$OBJECT_ID

# Create Az Role Assignments for K8s clusters
az role assignment create --role "Azure Arc Kubernetes Viewer" \
                          --assignee $OBJECT_ID \
                          --scope $RESOURCE_ID
az role assignment create --role "Azure Arc Enabled Kubernetes Cluster User Role" \
                          --assignee $OBJECT_ID \
                          --scope $RESOURCE_ID