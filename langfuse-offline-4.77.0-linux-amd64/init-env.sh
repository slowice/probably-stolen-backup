#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
if [ -e .env ]; then
  echo '.env already exists; preserve the existing keys.' >&2
  exit 1
fi
command -v openssl >/dev/null 2>&1 || { echo 'openssl is required to generate secrets.' >&2; exit 1; }
umask 077
pg=$(openssl rand -hex 32)
s3=$(openssl rand -hex 32)
salt=$(openssl rand -hex 32)
enc=$(openssl rand -hex 32)
auth=$(openssl rand -hex 32)
clickhouse=$(openssl rand -hex 32)
redis=$(openssl rand -hex 32)
cat > .env <<EOF
COMPOSE_PROJECT_NAME=langfuse-offline
NEXTAUTH_URL=http://localhost:3000
TELEMETRY_ENABLED=false
POSTGRES_PASSWORD=$pg
DATABASE_URL=postgresql://postgres:$pg@postgres:5432/postgres
SALT=$salt
ENCRYPTION_KEY=$enc
NEXTAUTH_SECRET=$auth
CLICKHOUSE_PASSWORD=$clickhouse
REDIS_AUTH=$redis
MINIO_ROOT_PASSWORD=$s3
LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY=$s3
LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY=$s3
LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY=$s3
EOF
echo 'Created .env with new local secrets. Preserve it for future restarts.'
