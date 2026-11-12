param([string]$OutputPath = (Join-Path $PSScriptRoot '.env'))
$ErrorActionPreference = 'Stop'
if (Test-Path -LiteralPath $OutputPath) { throw 'The .env file already exists. Preserve the existing keys.' }
function New-LocalSecret {
    $bytes = New-Object byte[] 32
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    [BitConverter]::ToString($bytes).Replace('-', '').ToLowerInvariant()
}
$pg = New-LocalSecret
$s3 = New-LocalSecret
$lines = @(
    'COMPOSE_PROJECT_NAME=langfuse-offline',
    'NEXTAUTH_URL=http://localhost:3000',
    'TELEMETRY_ENABLED=false',
    "POSTGRES_PASSWORD=$pg",
    "DATABASE_URL=postgresql://postgres:${pg}@postgres:5432/postgres",
    "SALT=$(New-LocalSecret)",
    "ENCRYPTION_KEY=$(New-LocalSecret)",
    "NEXTAUTH_SECRET=$(New-LocalSecret)",
    "CLICKHOUSE_PASSWORD=$(New-LocalSecret)",
    "REDIS_AUTH=$(New-LocalSecret)",
    "MINIO_ROOT_PASSWORD=$s3",
    "LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY=$s3",
    "LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY=$s3",
    "LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY=$s3"
)
[IO.File]::WriteAllLines($OutputPath, $lines, (New-Object Text.UTF8Encoding($false)))
Write-Host 'Created .env with new local secrets. Keep this file for future restarts.'
