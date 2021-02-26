#!/bin/bash

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

cp ca.pem worker-0-key.pem worker-1-key.pem worker-0.pem worker-1.pem worker-0.kubeconfig worker-1.kubeconfig kube-proxy.kubeconfig ../ansible/files/workers
cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig encryption-config.yaml ../ansible/files/controllers
