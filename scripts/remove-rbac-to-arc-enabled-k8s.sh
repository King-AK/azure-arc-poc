cluster_name=$1
rg_name=$2
subscription_id=$3
tenant_id=$4

access_check_custom_role_def_path="custom-role/accessCheck.json"
access_check_custom_role_def=$(jq --arg scope "/subscriptions/$subscription_id" '.AssignableScopes[0] = $scope' $access_check_custom_role_def_path)
rbac_config_file_path="tmp/rbac-setup-config.json"


# Remove Client Application
client_app_display_name="${cluster_name}-client"
client_app_id=$(jq -r .clientAppID $rbac_config_file_path)
echo "Removing client application [$client_app_display_name] ..."
az ad app delete --id "${client_app_id}"
echo "Removed client application [$client_app_display_name] ..."
echo "NOTE: Go to the AD Overview Page > App registrations > Deleted Applications to permanently delete [$client_app_display_name] and free API URI ..."
## TODO automate permanent app deletion with AD graph at a later point

# Remove Server Application Role Assignment
server_app_display_name="${cluster_name}-server"
server_app_id=$(jq -r .serverAppID $rbac_config_file_path)
custom_role_id=$(jq -r .customRoleID $rbac_config_file_path)
echo "Removing custom role assignment on application [$server_app_display_name] ..."
az role assignment delete --role "${custom_role_id}" \
                          --assignee "${server_app_id}" \
                          --scope "/subscriptions/$subscription_id"
echo "Removed custom role assignment on application [$server_app_display_name] ..."

# Remove Server Application
echo "Removing server application [$server_app_display_name] ..."
az ad app delete --id "${server_app_id}"
echo "Removed server application [$server_app_display_name] ..."
echo "NOTE: Go to the AD Overview Page > App registrations > Deleted Applications to permanently delete [$server_app_display_name] and free API URI ..."
## TODO automate permanent app deletion with AD graph at a later point

# Remove Custom Role
role_name=$(jq -r .Name $access_check_custom_role_def_path)
role_scope="/subscriptions/$subscription_id" 
echo "Removing custom role [$role_name] ..."
az role definition delete --name "$role_name" --scope "$role_scope"
echo "Removed custom Role [$role_name] ..."
