# vscode-docker 项目总结

## 📋 项目信息

- **项目名称**: vscode-docker
- **GitHub 仓库**: https://github.com/iflyelf/vscode-docker
- **Docker Hub**: https://hub.docker.com/r/iflyelf/code-server
- **华为云 SWR**: swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server
- **创建时间**: 2026-11-03

## 🎯 项目目标

将 code-server（VSCode Web 版）容器化，提供完整的远程开发环境。

## ✅ 已完成功能

### 1. Dockerfile（多阶段构建）

- ✅ **构建阶段**: 基于 `iflyelf/ubuntu:latest`，包含完整工具链
- ✅ **运行阶段**: 基于 `iflyelf/ubuntu:lite`，精简镜像体积
- ✅ **多架构支持**: `linux/amd64`, `linux/arm64`
- ✅ **健康检查**: 自动检测服务运行状态
- ✅ **版本管理**: 通过 ARG 变量管理 code-server 版本

**文件位置**: `/xiaonuo/workspace/docker/vscode-docker/Dockerfile`

### 2. Docker Compose 配置

- ✅ 完整的服务定义
- ✅ 配置文件挂载（`config/`）
- ✅ 数据目录挂载（`data/`）
- ✅ 工作区挂载（`workspace/`）
- ✅ 环境变量配置
- ✅ 端口映射（8888）

**文件位置**: `/xiaonuo/workspace/docker/vscode-docker/docker-compose.yml`

### 3. 配置文件

#### config/config.yaml
- ✅ 监听地址配置
- ✅ 认证方式配置
- ✅ 密码配置

#### data/User/settings.json
- ✅ 完整的 VSCode 配置
- ✅ 中文语言设置
- ✅ 每个配置项都有详细注释
- ✅ 敏感信息使用占位符
- ✅ 可选配置注释掉避免误用

### 4. GitHub Actions 自动构建

- ✅ 推送到 `main` 分支自动触发
- ✅ 自动检测 code-server 最新版本
- ✅ 多架构构建（amd64, arm64）
- ✅ 同时推送到 Docker Hub 和华为云 SWR
- ✅ 自动更新 Dockerfile 和 README 版本号
- ✅ 清理旧的 workflow runs（保留最近 3 次）
- ✅ 构建缓存加速
- ✅ 并发控制（取消旧构建）

**文件位置**: `/xiaonuo/workspace/docker/vscode-docker/.github/workflows/docker-publish.yml`

### 5. 文档

- ✅ **README.md**: 完整的使用文档
  - 快速开始
  - 配置说明
  - 扩展管理
  - 数据持久化
  - 高级用法
  - 故障排查
  
- ✅ **GITHUB_SECRETS.md**: GitHub Secrets 配置说明
  - Secrets 配置步骤
  - 验证方法
  - 故障排查

- ✅ **deploy.sh**: 一键部署脚本
  - 自动创建目录
  - 自动创建配置文件
  - 自动拉取镜像
  - 自动启动服务

### 6. 项目结构

```
vscode-docker/
├── .github/
│   └── workflows/
│       └── docker-publish.yml    # GitHub Actions 工作流
├── config/
│   └── config.yaml              # code-server 配置文件
├── data/
│   └── User/
│       └── settings.json        # VSCode 用户配置
├── workspace/                   # 工作区目录
│   └── .gitkeep
├── .gitignore                   # Git 忽略文件
├── Dockerfile                   # 多阶段构建文件
├── docker-compose.yml           # Docker Compose 配置
├── deploy.sh                    # 部署脚本
├── README.md                    # 项目文档
└── GITHUB_SECRETS.md            # Secrets 配置说明
```

## 🔧 技术特点

### 1. 多阶段构建

- **构建阶段**: 使用 `iflyelf/ubuntu:latest`（包含完整工具链）
- **运行阶段**: 使用 `iflyelf/ubuntu:lite`（精简镜像）
- **优势**: 构建快速、镜像体积小

### 2. 配置挂载

- **config/**: code-server 配置文件
- **data/**: 用户设置、扩展、工作区数据
- **workspace/**: 代码工作区
- **优势**: 数据持久化、配置灵活

### 3. 自动版本跟踪

- 自动检测 code-server 最新版本
- 自动更新 Dockerfile 和 README
- 自动构建新版本镜像

### 4. 多平台推送

- Docker Hub: 公开镜像，全球可访问
- 华为云 SWR: 国内加速，推荐国内用户使用

## 📦 镜像信息

### 当前版本

- **code-server 版本**: v4.144.0
- **基础镜像**: iflyelf/ubuntu:lite
- **支持架构**: linux/amd64, linux/arm64

### 镜像地址

```bash
# Docker Hub
docker pull iflyelf/code-server:latest
docker pull iflyelf/code-server:4.144.0

# 华为云 SWR（国内推荐）
docker pull swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:latest
docker pull swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:4.144.0
```

## 🚀 快速使用

### 方法 1: 使用 Docker Compose（推荐）

```bash
# 克隆仓库
git clone https://github.com/iflyelf/vscode-docker.git
cd vscode-docker

# 启动服务
docker-compose up -d

# 访问
# http://localhost:8888
# 密码: ysyh!9Sky
```

### 方法 2: 使用部署脚本

```bash
# 下载部署脚本
curl -fsSL https://raw.githubusercontent.com/iflyelf/vscode-docker/main/deploy.sh -o deploy.sh
chmod +x deploy.sh

# 执行部署
./deploy.sh
```

### 方法 3: 使用 Docker 命令

```bash
docker run -d \
  --name code-server \
  -p 8888:8888 \
  -v $(pwd)/config:/root/.config/code-server \
  -v $(pwd)/data:/root/.local/share/code-server \
  -v $(pwd)/workspace:/workspace \
  -e PASSWORD=ysyh!9Sky \
  --restart always \
  iflyelf/code-server:latest
```

## 🔐 GitHub Secrets 配置

在 GitHub 仓库中配置以下 Secrets：

1. **DOCKER_PASSWORD**: `ysyh!9Sky`
2. **HUAWEI_SWR_PASSWORD**: `89859da8eda4ca25a0d0e6012c798c479ff11634b41d0b99abb08fead6ec1af6`

详见 `GITHUB_SECRETS.md`

## 📝 配置说明

### 修改密码

编辑 `config/config.yaml`：

```yaml
password: 你的新密码
```

### 自定义配置

编辑 `data/User/settings.json`，根据注释修改配置项。

### 代理配置

如果需要配置代理，修改 `data/User/settings.json`：

```json
"terminal.integrated.env.windows": {
  "http_proxy": "http://YOUR_PROXY_HOST:PORT",
  "https_proxy": "http://YOUR_PROXY_HOST:PORT"
}
```

## 🎉 项目亮点

1. ✅ **多阶段构建**: 构建快、镜像小
2. ✅ **多架构支持**: amd64、arm64 全覆盖
3. ✅ **完整注释**: 每个配置项都有详细说明
4. ✅ **自动构建**: GitHub Actions 全自动
5. ✅ **版本跟踪**: 自动检测并更新最新版本
6. ✅ **数据持久化**: 配置和数据完全挂载
7. ✅ **中文支持**: 预配置中文界面
8. ✅ **多平台推送**: Docker Hub + 华为云 SWR
9. ✅ **安全脱敏**: 敏感信息使用占位符
10. ✅ **完整文档**: README + Secrets 说明

## 🔄 后续维护

### 自动维护

- GitHub Actions 会自动检测 code-server 新版本
- 自动构建并推送新镜像
- 自动更新文档

### 手动触发构建

```bash
# 在 GitHub Actions 页面点击 "Run workflow"
# 或使用 API
curl -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/iflyelf/vscode-docker/actions/workflows/docker-publish.yml/dispatches" \
  -d '{"ref":"main"}'
```

## 📚 相关链接

- **GitHub 仓库**: https://github.com/iflyelf/vscode-docker
- **Docker Hub**: https://hub.docker.com/r/iflyelf/code-server
- **华为云 SWR**: swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server
- **code-server 官方**: https://github.com/coder/code-server
- **基础镜像**: https://github.com/iflyelf/ubuntu-lite

## 🙏 致谢

- [code-server](https://github.com/coder/code-server) - 官方项目
- [iflyelf/ubuntu-lite](https://github.com/iflyelf/ubuntu-lite) - 基础镜像

---

**项目创建者**: iflyelf  
**创建时间**: 2026-11-03  
**最后更新**: 2026-11-03
