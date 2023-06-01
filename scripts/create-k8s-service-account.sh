# Create service account in default namespace
kubectl create serviceaccount demo-user -n default

# Create ClusterRoleBinding to grant service account appropriate permissions on the cluster
kubectl create clusterrolebinding demo-user-binding \
                        --clusterrole cluster-admin \
                        --serviceaccount default:demo-user

# Create Service Account Token
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: demo-user-secret
  annotations:
    kubernetes.io/service-account.name: demo-user
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl get secret demo-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')

# Save token output to file
mkdir -p tmp
echo $TOKEN > tmp/demo-user-secret

# Above token can be used in portal to get access to cluster namespaces from portal

