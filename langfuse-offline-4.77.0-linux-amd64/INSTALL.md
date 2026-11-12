# Langfuse 4.77.0 离线安装包

本包从蓝区已运行的 Langfuse Docker 容器所用镜像导出，目标架构为 **linux/amd64**（Intel/AMD x86_64）。使用以镜像 ID 命名的本地标签，Compose 设置 `pull_policy: never`，启动不依赖镜像仓库。ARM64/鲲鹏机器不能直接按原生架构使用本包。

## 包含什么

- `langfuse-images.tar`：Web、Worker、ClickHouse、PostgreSQL、Redis、MinIO 共六个镜像。
- `docker-compose.yml`：仅绑定本机端口的离线部署配置。
- `images.json`：镜像 ID、平台、大小及原仓库摘要。
- `init-env.ps1` / `init-env.sh`：在目标机器生成全新的随机密钥；已有 `.env` 时拒绝覆盖。
- `SHA256SUMS.txt`：传输后的完整性校验。

**必须把整个目录带到黄区。** 这是全新实例安装包，不含蓝区账号、API Key、数据库、用户日志或本地日志导入工具。不含 Docker 引擎、Docker Compose、WSL 或 Windows 安装程序。

## 目标机器前提

已安装并启动 Docker Linux 容器引擎及 Compose v2 或更新版；Linux x86_64，或 Windows Docker Desktop 的 Linux 容器模式。建议 4 核、16 GB 内存，磁盘至少预留 15 GB 用于导入和启动，后续另留日志数据空间。

```text
docker version
docker compose version
```

如果黄区连 Docker 本体也没有安装，此镜像包不能替代 Docker；需按目标操作系统另行准备 Docker/Compose 的离线安装介质。

## Windows 安装

在本目录打开 PowerShell：

```powershell
# 与 SHA256SUMS.txt 中 langfuse-images.tar 的值比较
Get-FileHash .\langfuse-images.tar -Algorithm SHA256

docker load -i .\langfuse-images.tar
if ($LASTEXITCODE -ne 0) { throw '镜像导入失败，请先处理错误' }
powershell -NoProfile -ExecutionPolicy Bypass -File .\init-env.ps1
docker compose config --quiet

# 先启动 Web，由它完成数据库初始化
docker compose up -d --pull never langfuse-web
```

等待初始化，通常需要数分钟。以下请求成功并返回 `status: OK` 后，再启动 Worker：

```powershell
Invoke-RestMethod http://localhost:3000/api/public/health
docker compose up -d --pull never langfuse-worker
Invoke-RestMethod http://localhost:3030/api/health
docker compose ps
```

## Linux 安装

在本目录终端执行（当前账号需要有 Docker 使用权限）：

```sh
sha256sum -c SHA256SUMS.txt
docker load -i langfuse-images.tar
sh init-env.sh
docker compose config --quiet
docker compose up -d --pull never langfuse-web
```

等待下面健康检查返回 `status: OK`，再启动 Worker：

```sh
curl --fail http://localhost:3000/api/public/health
docker compose up -d --pull never langfuse-worker
curl --fail http://localhost:3030/api/health
docker compose ps
```

如果健康检查暂未成功，用 `docker compose logs --tail=100 langfuse-web` 查看初始化进度，不要删除数据卷。

## 使用

在**部署机器本机**访问 http://localhost:3000 ，点击 Sign up 创建本地账号、组织和项目，无默认账号。所有端口只绑定 127.0.0.1；其他机器无法直接访问。这也意味着在远程服务器部署后，需要本机浏览器或 SSH 隧道访问，不能直接用服务器 IP 打开。

基本的登录、日志写入、Trace 查询使用本地服务。未配置模型服务，自动评估/AI 功能不会因此获得离线模型能力；外部文档和第三方登录不包含在离线包中。

本次打包只固定镜像与部署配置，没有把现有蓝区数据迁移到黄区。后续接入黄区 Matrix 日志应在黄区单独配置，不复用蓝区项目密钥。

## 日常管理

```sh
docker compose stop
docker compose start
docker compose ps
docker compose logs --tail=100 langfuse-web langfuse-worker
```

保留 `.env`，尤其是 `ENCRYPTION_KEY`；数据在 Docker 命名卷中。不要执行 `docker compose down -v`，它会删除数据卷。端口被占用时，应先调整映射及 NEXTAUTH_URL、媒体访问地址，再启动。
