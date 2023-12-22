#!/bin/bash
set -euxo pipefail

# Create the dex namespace
kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: dex
EOF

# Generate and inject the TLS certificate
dex_tls_path="dex-tls"

mkdir -p $dex_tls_path

cat << EOF > $dex_tls_path/req.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = dex.example.com
EOF

openssl genrsa -out $dex_tls_path/ca-key.pem 2048
openssl req -x509 -new -nodes -key $dex_tls_path/ca-key.pem -days 10 -out $dex_tls_path/ca.pem -subj "/CN=kube-ca"

openssl genrsa -out $dex_tls_path/key.pem 2048
openssl req -new -key $dex_tls_path/key.pem -out $dex_tls_path/csr.pem -subj "/CN=kube-ca" -config $dex_tls_path/req.cnf
openssl x509 -req -in $dex_tls_path/csr.pem -CA $dex_tls_path/ca.pem -CAkey $dex_tls_path/ca-key.pem -CAcreateserial -out $dex_tls_path/cert.pem -days 10 -extensions v3_req -extfile $dex_tls_path/req.cnf

kubectl create secret tls dex-tls -n dex --key="$dex_tls_path/key.pem" --cert="$dex_tls_path/cert.pem"


# Deploy DEX
kubectl apply -f - <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: dex
  name: dex
  namespace: dex
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: dex
  template:
    metadata:
      labels:
        app.kubernetes.io/name: dex
    spec:
      serviceAccountName: dex # This is created below
      containers:
      - image: ghcr.io/dexidp/dex:latest-distroless
        name: dex
        command: ["/usr/local/bin/dex", "serve", "/etc/dex/cfg/config.yaml"]

        ports:
        - name: https
          containerPort: 5556

        volumeMounts:
        - name: config
          mountPath: /etc/dex/cfg
        - name: tls
          mountPath: /etc/dex/tls

        readinessProbe:
          httpGet:
            path: /healthz
            port: 5556
            scheme: HTTPS
      volumes:
      - name: config
        configMap:
          name: dex
          items:
          - key: config.yaml
            path: config.yaml
      - name: tls
        secret:
          secretName: dex-tls
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dex
  namespace: dex
data:
  config.yaml: |
    issuer: https://dex.example.com:32000
    storage:
      type: kubernetes
      config:
        inCluster: true
    web:
      https: 0.0.0.0:5556
      tlsCert: /etc/dex/tls/tls.crt
      tlsKey: /etc/dex/tls/tls.key
    oauth2:
      skipApprovalScreen: true

    staticClients:
    - id: example-app
      redirectURIs:
      - 'http://127.0.0.1:5555/callback'
      name: 'Example App'
      secret: ZXhhbXBsZS1hcHAtc2VjcmV0

    enablePasswordDB: true
    staticPasswords:
    - email: "admin@example.com"
      # bcrypt hash of the string "password": $(echo password | htpasswd -BinC 10 admin | cut -d: -f2)
      hash: "\$2y\$10\$Ni3teuwLFIggjhfH1g4YVeDlKCNiwBOFd/w5EzWCkPkOEDTMPv1Ji"
      username: "admin"
      userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
---
apiVersion: v1
kind: Service
metadata:
  name: dex
  namespace: dex
spec:
  type: NodePort
  ports:
  - name: dex
    port: 5556
    protocol: TCP
    targetPort: 5556
    nodePort: 32000
  selector:
    app.kubernetes.io/name: dex
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: dex
  name: dex
  namespace: dex
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dex
rules:
- apiGroups: ["dex.coreos.com"] # API group created by dex
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["create"] # To manage its own resources, dex must be able to create customresourcedefinitions
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dex
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dex
subjects:
- kind: ServiceAccount
  name: dex           # Service account assigned to the dex pod, created above
  namespace: dex      # The namespace dex is running in
EOF
