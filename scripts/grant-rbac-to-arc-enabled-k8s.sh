cluster_name=$1
rg_name=$2
subscription_id=$3
tenant_id=$4
server_unique_suffix="cc96" # NOTE: parametrize in production situation
client_unique_suffix="cc97" # NOTE: parametrize in production situation

access_check_custom_role_def_path="custom-role/accessCheck.json"
access_check_custom_role_def=$(jq --arg scope "/subscriptions/$subscription_id" '.AssignableScopes[0] = $scope' $access_check_custom_role_def_path)
server_api_permissions_path="server-app-api-permissions/oauth2-permissions.json"
rbac_config_file_path="tmp/rbac-setup-config.json"

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

# Create custom role assignment on Server Application
echo "Assigning custom role [$role_name] on server application [$server_app_display_name] ..."
az role assignment create --role "${ROLE_ID}" \
                          --assignee "${SERVER_APP_ID}" \
                          --scope "/subscriptions/$subscription_id"
echo "Assigned custom role [$role_name] on server application [$server_app_display_name] ..."


# Create Client Application
client_app_display_name="${cluster_name}-client"
client_identifier_uri="api://${tenant_id}/${client_unique_suffix}"
echo "Creating client application [$client_app_display_name] ..."
CLIENT_APP_ID=$(az ad app create --display-name "${client_app_display_name}" \
                                 --is-fallback-public-client \
                                 --public-client-redirect-uris "${client_identifier_uri}" \
                                 | jq -r .appId)
echo "Created client application [$client_app_display_name] with identifier uri [$client_identifier_uri] and app id [$CLIENT_APP_ID] ..."

# Create Service Principal for Client Application
echo "Creating service principal for client application [$client_app_display_name] ..."
az ad sp create --id "${CLIENT_APP_ID}"
echo "Created service principal for client application [$client_app_display_name] ..."

# Grant required permissions for client application RBAC
oAuthPermissionId=$(az ad app show --id "${SERVER_APP_ID}" --query "api.oauth2PermissionScopes[0].id" -o tsv)

echo "Updating permissions of client application [$client_app_display_name] ..."
az ad app permission add --id "${CLIENT_APP_ID}" --api "${SERVER_APP_ID}" --api-permissions $oAuthPermissionId=Scope
RESOURCE_APP_ID=$(az ad app show --id "${CLIENT_APP_ID}"  --query "requiredResourceAccess[0].resourceAppId" -o tsv)
az ad app permission grant --id "${CLIENT_APP_ID}" --api "${RESOURCE_APP_ID}" --scope User.Read
az ad app update --id ${CLIENT_APP_ID} --set  signInAudience=AzureADMyOrg
CLIENT_OBJECT_ID=$(az ad app show --id "${CLIENT_APP_ID}" --query "id" -o tsv)
az rest --method PATCH --headers "Content-Type=application/json" --uri https://graph.microsoft.com/v1.0/applications/${CLIENT_OBJECT_ID}/ --body '{"api":{"requestedAccessTokenVersion": 1}}'
echo "Updated permissions of client application [$client_app_display_name] ..."


# Populate config file
echo "Populating config file at path [$rbac_config_file_path]..."
echo "{}" | \
    jq --arg roleid $ROLE_ID '.customRoleID = $roleid' | \
    jq --arg appid $SERVER_APP_ID '.serverAppID = $appid' | \
    jq --arg secret $SERVER_APP_SECRET '.serverAppSecret = $secret' | \
    jq --arg appid $CLIENT_APP_ID '.clientAppID = $appid' > $rbac_config_file_path
echo "Populated config file at path [$rbac_config_file_path] ..."

