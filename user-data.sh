#!/bin/bash

dnf install -y docker

systemctl enable --now docker

cat > /opt/deploy.sh <<'EOF'
#!/bin/bash

set -e

export AWS_DEFAULT_REGION=ap-south-1

ACCOUNT_ID=189761005684
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/hello-jenkins:latest"

# Login to AWS ECR
aws ecr get-login-password --region "$AWS_DEFAULT_REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

# Pull latest image
docker pull "$IMAGE"

# Replace the existing website container
docker rm -f web 2>/dev/null || true

# Start the website on port 80
docker run -d \
  --name web \
  --restart unless-stopped \
  -p 80:80 \
  "$IMAGE"
EOF

chmod +x /opt/deploy.sh

/opt/deploy.sh
