cluster_name=$1
rg_name=$2
subscription_id=$3
tenant_id=$4
server_unique_suffix=$5
SP_NAME=$cluster_name
access_check_custom_role_def_path="custom-role/accessCheck.json"
access_check_custom_role_def=$(jq --arg scope "/subscriptions/$subscription_id" '.AssignableScopes[0] = $scope' $access_check_custom_role_def_path)
server_api_permissions_path="server-app-api-permissions/oauth2-permissions.json"

# Create Custom Role
role_name=$(jq -r .Name $access_check_custom_role_def_path)
echo "Creating custom role [$role_name] ..."
ROLE_ID=$(az role definition create --role-definition "$access_check_custom_role_def" \
                                    | jq -r .id)
echo "Created custom role [$role_name] with id [$ROLE_ID] ..."


# Create Server Application
server_app_display_name="${cluster_name}-server"
server_identifier_uri="api://${tenant_id}/${server_unique_suffix}"
echo "Creating server application [$server_app_display_name] ..."
SERVER_APP_ID=$(az ad app create --display-name "${server_app_display_name}" \
                                 --identifier-uris "${server_identifier_uri}" \
                                 | jq -r .appId)
echo "Created server application [$server_app_display_name] with identifier uri [$server_identifier_uri] and app id [$SERVER_APP_ID] ..."


# Grant permissions to Server Application
jq --arg server_app_id "$SERVER_APP_ID" '.oauth2PermissionScopes[0].id = $server_app_id' $server_api_permissions_path > tmp/server_api_permissions.json

echo "Updating permissions of server application [$server_app_display_name] ..."
az ad app update --id "${SERVER_APP_ID}" --set groupMembershipClaims=All
az ad app update --id ${SERVER_APP_ID} --set  api=@tmp/server_api_permissions.json
az ad app update --id ${SERVER_APP_ID} --set  signInAudience=AzureADMyOrg
SERVER_OBJECT_ID=$(az ad app show --id "${SERVER_APP_ID}" --query "id" -o tsv)
az rest --method PATCH --headers "Content-Type=application/json" --uri https://graph.microsoft.com/v1.0/applications/${SERVER_OBJECT_ID}/ --body '{"api":{"requestedAccessTokenVersion": 1}}'
echo "Updated permissions of server application [$server_app_display_name] ..."

# Create Service Principal for Server Application and collect the credential
echo "Creating service principal for server application [$server_app_display_name] ..."
az ad sp create --id "${SERVER_APP_ID}"
SERVER_APP_SECRET=$(az ad sp credential reset --id "${SERVER_APP_ID}" \
                                              --query password -o tsv)
echo "Created service principal for server application [$server_app_display_name] ..."

# Grant "Sign in and read user profile" API permissions to the Server Application
echo "Granting 'Sign in and read user profile' API permissions for server application [$server_app_display_name] ..."
az ad app permission add --id "${SERVER_APP_ID}" \
                         --api "00000003-0000-0000-c000-000000000000" \
                         --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id "${SERVER_APP_ID}" \
                           --api 00000003-0000-0000-c000-000000000000 \
                           --scope User.Read
echo "Granted 'Sign in and read user profile' API permissions for server application [$server_app_display_name] ..."






# # Collect Object ID
# OBJECT_ID=$(az ad signed-in-user show --query userPrincipalName -o tsv)

# # Collect Connected K8s resource id
# RESOURCE_ID=$(az connectedk8s show --name docker-desktop \
#                                    --resource-group domain-a | jq -r .id)

# # TODO: Add steps to create server application
# # Create Server SP 
# echo "Creating SP $SP_NAME ..."
# OUTPUT=$(az ad sp create-for-rbac --name $SP_NAME)
# APP_ID=$(echo $OUTPUT | jq -r .appId)
# SP_SECRET=$(echo $OUTPUT | jq -r .password)
# echo "Created SP $SP_NAME with APP ID: $APP_ID ..."

# # Update the application's group membership claims
# az ad app update --id "${SERVER_APP_ID}" --set groupMembershipClaims=All
# az ad app update --id ${SERVER_APP_ID} --set  api=@oauth2-permissions.json
# az ad app update --id ${SERVER_APP_ID} --set  signInAudience=AzureADMyOrg
# SERVER_OBJECT_ID=$(az ad app show --id "${SERVER_APP_ID}" --query "id" -o tsv)
# az rest --method PATCH --headers "Content-Type=application/json" --uri https://graph.microsoft.com/v1.0/applications/${SERVER_OBJECT_ID}/ --body '{"api":{"requestedAccessTokenVersion": 1}}'

# # Grant "Sign in and read user profile" API permissions to the application
# az ad app permission add --id "${SERVER_APP_ID}" --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
# az ad app permission grant --id "${SERVER_APP_ID}" --api 00000003-0000-0000-c000-000000000000 --scope User.Read

# # TODO: figure out if client stuff needed

# # Create custom role for server application
# ROLE_ID=$(az role definition create --role-definition ./accessCheck.json --query id -o tsv)

# # Create a role assignment on the server application using the custom role
# az role assignment create --role "${ROLE_ID}" --assignee "${SERVER_APP_ID}" --scope /subscriptions/<subscription-id>

# # Enable RBAC on the Arc Enabled k8s cluster
# az connectedk8s enable-features --name <clusterName> \
#                                 --resource-group <resourceGroupName> \
#                                 --features azure-rbac \
#                                 --app-id "${SERVER_APP_ID}" \
#                                 --app-secret "${SERVER_APP_SECRET}"


# # Create ClusterRoleBinding mapped to AD entity
# # kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin \
# #                                                     --user=$OBJECT_ID

# # Create Az Role Assignments for K8s clusters
# az role assignment create --role "Azure Arc Kubernetes Viewer" \
#                           --assignee $OBJECT_ID \
#                           --scope $RESOURCE_ID
# az role assignment create --role "Azure Arc Enabled Kubernetes Cluster User Role" \
#                           --assignee $OBJECT_ID \
#                           --scope $RESOURCE_ID