# Langfuse 4.77.0 离线安装包（Linux AMD64）

适用于已有 Docker + Compose 的 x86_64 机器，或 Windows Docker Desktop 的 Linux 容器模式。

## 下载

- [完整离线包 ZIP（约 898 MiB）](https://github.com/slowice/probably-stolen-backup/releases/download/langfuse-4.77.0-offline-20261112/langfuse-offline-4.77.0-linux-amd64.zip)
- [ZIP 的 SHA-256 校验文件](https://github.com/slowice/probably-stolen-backup/releases/download/langfuse-4.77.0-offline-20261112/langfuse-offline-4.77.0-linux-amd64.zip.sha256)
- [Release 页面](https://github.com/slowice/probably-stolen-backup/releases/tag/langfuse-4.77.0-offline-20261112)

这是私有仓库，下载时需要登录有权限的 GitHub 账号。大包放在 Release 附件，不在 Git 历史中；只下载仓库源码不会得到镜像。

## 安装

下载完整 ZIP，解压后按包内 README 操作；也可阅读本目录的 [安装说明](INSTALL.md)。

ZIP 内含 `langfuse-images.tar`，包含 Langfuse Web、Worker、ClickHouse、PostgreSQL、Redis、MinIO 六个镜像。先运行 `docker load -i langfuse-images.tar`，再运行对应操作系统的 `init-env` 脚本生成新密钥，最后按说明启动服务。

镜像架构为 `linux/amd64`，不含 Docker/Compose/WSL 安装程序，不含蓝区账号、密钥或业务数据。Compose 已禁止自动拉取镜像，仅绑定本机端口。

## 校验与版本

- 镜像从当前运行容器使用的 image ID 导出，使用固定的本地标签。
- 已在蓝区通过 `docker load` 回读、六个 image ID 比对和 Compose 配置解析验证；尚未在黄区实际启动。
- `images.json` 为镜像清单。
- `ARCHIVE-SHA256SUMS.txt` 是 **ZIP 解压目录内** 各文件的校验清单，其中 README.md 对应包内安装说明，并非本页面。
- `langfuse-offline-4.77.0-linux-amd64.zip.sha256` 校验整个 ZIP。
