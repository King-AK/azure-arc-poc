# Delete Service Account Token
kubectl delete -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: demo-user-secret
  annotations:
    kubernetes.io/service-account.name: demo-user
type: kubernetes.io/service-account-token
EOF

# Delete ClusterRoleBinding to grant service account appropriate permissions on the cluster
kubectl delete clusterrolebinding demo-user-binding

# Delete service account in default namespace
kubectl delete serviceaccount demo-user -n default
