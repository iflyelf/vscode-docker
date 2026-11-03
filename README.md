# code-server Docker 镜像

[![Docker Image](https://img.shields.io/badge/docker-iflyelf%2Fcode--server-blue)](https://hub.docker.com/r/iflyelf/code-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/iflyelf/code-server)](https://hub.docker.com/r/iflyelf/code-server)
[![Docker Image Size](https://img.shields.io/docker/image-size/iflyelf/code-server/latest)](https://hub.docker.com/r/iflyelf/code-server)
[![GitHub](https://img.shields.io/github/license/iflyelf/vscode-docker)](https://github.com/iflyelf/vscode-docker)

基于 Ubuntu 的 code-server Docker 镜像，提供完整的 VSCode Web 开发环境。

---

## 目录

1. [特性](#特性)
2. [快速开始](#快速开始)
3. [配置说明](#配置说明)
4. [扩展管理](#扩展管理)
5. [数据持久化](#数据持久化)
6. [高级用法](#高级用法)
7. [故障排查](#故障排查)
8. [构建镜像](#构建镜像)
9. [GitHub Actions 配置](#github-actions-配置)
10. [项目信息](#项目信息)

---

## 特性

- ✅ 基于 `iflyelf/ubuntu:lite` 精简镜像
- ✅ 多阶段构建，镜像体积更小
- ✅ 支持多架构：`linux/amd64`, `linux/arm64`
- ✅ 预配置中文界面
- ✅ 自动跟踪 code-server 最新版本
- ✅ 配置文件和数据目录挂载
- ✅ 健康检查
- ✅ 使用 tini 作为 init 进程

---

## 快速开始

### 使用 Docker Compose（推荐）

```bash
# 下载 docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/iflyelf/vscode-docker/main/docker-compose.yml -o docker-compose.yml

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 使用部署脚本

```bash
# 下载部署脚本
curl -fsSL https://raw.githubusercontent.com/iflyelf/vscode-docker/main/deploy.sh -o deploy.sh
chmod +x deploy.sh

# 执行部署
./deploy.sh
```

### 使用 Docker 命令

```bash
docker run -d \
  --name code-server \
  -p 8888:8888 \
  -v $(pwd)/config:/root/.config/code-server \
  -v $(pwd)/data:/root/.local/share/code-server \
  -v $(pwd)/workspace:/workspace \
  -e PASSWORD=your_password \
  -e TZ=Asia/Shanghai \
  --restart always \
  iflyelf/code-server:latest
```

### 国内镜像加速

使用华为云 SWR 镜像：

```bash
docker run -d \
  --name code-server \
  -p 8888:8888 \
  -v $(pwd)/config:/root/.config/code-server \
  -v $(pwd)/data:/root/.local/share/code-server \
  -e PASSWORD=your_password \
  --restart always \
  swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:latest
```

### 访问服务

打开浏览器访问：

```
http://localhost:8888
```

默认密码：请在部署时设置

---

## 配置说明

### 目录结构

```
.
├── config/              # code-server 配置文件目录
│   └── config.yaml     # 主配置文件
├── data/               # code-server 数据目录
│   ├── User/          # 用户设置
│   │   └── settings.json
│   └── extensions/    # 扩展目录
└── workspace/         # 工作区目录（可选）
```

### 配置文件

**config/config.yaml**：

```yaml
bind-addr: 0.0.0.0:8888
auth: password
password: your_password
cert: false
```

**配置说明**：
- `bind-addr`: 监听地址和端口
  - `0.0.0.0` - 允许远程访问
  - `127.0.0.1` - 仅本地访问
- `auth`: 认证方式（password / none）
- `password`: 登录密码
- `cert`: HTTPS 证书路径（false 表示使用 HTTP）

**data/User/settings.json** 示例：

```json
{
    "locale": "zh-cn",
    "workbench.colorTheme": "Default Dark+",
    "editor.fontSize": 14,
    "editor.tabSize": 2,
    "files.autoSave": "onFocusChange",
    "editor.formatOnSave": true,
    "terminal.integrated.fontSize": 14,
    "telemetry.telemetryLevel": "off"
}
```

完整配置请参考项目中的 `data/User/settings.json`，每个配置项都有详细的中文注释。

### 环境变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `PASSWORD` | 登录密码 | - | `your_password` |
| `CODE_SERVER_PORT` | 监听端口 | `8888` | `8080` |
| `CODE_SERVER_PROXY` | 代理域名（用于反向代理） | - | `code.example.com:443` |
| `TZ` | 时区 | `Asia/Shanghai` | `UTC` |
| `LANG` | 语言 | `zh_CN.UTF-8` | `en_US.UTF-8` |

**使用示例**：

```bash
# 使用自定义端口
docker run -d \
  -e PASSWORD=your_password \
  -e CODE_SERVER_PORT=8080 \
  -p 8080:8080 \
  iflyelf/code-server:latest

# 配置反向代理
docker run -d \
  -e PASSWORD=your_password \
  -e CODE_SERVER_PROXY=code.example.com:443 \
  iflyelf/code-server:latest
```

**docker-compose.yml 示例**：

```yaml
environment:
  PASSWORD: your_password
  CODE_SERVER_PORT: 8888
  CODE_SERVER_PROXY: code.example.com:443
  TZ: Asia/Shanghai
```

### 修改密码

编辑 `config/config.yaml`：

```yaml
password: 你的新密码
```

重启容器：

```bash
docker-compose restart
```

---

## 扩展管理

### 在 Web UI 中安装

1. 点击左侧扩展图标
2. 搜索并安装所需扩展

### 通过命令行安装

```bash
# 进入容器
docker exec -it code-server /bin/zsh

# 安装中文语言包
code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans

# 安装其他扩展
code-server --install-extension eamodio.gitlens
code-server --install-extension esbenp.prettier-vscode
code-server --install-extension dbaeumer.vscode-eslint
```

### 批量安装扩展

创建 `extensions.txt`：

```
MS-CEINTL.vscode-language-pack-zh-hans
eamodio.gitlens
esbenp.prettier-vscode
dbaeumer.vscode-eslint
ms-azuretools.vscode-docker
golang.go
ms-python.python
redhat.vscode-yaml
```

批量安装：

```bash
docker exec -it code-server /bin/zsh -c "cat /workspace/extensions.txt | xargs -L 1 code-server --install-extension"
```

### 常用扩展推荐

- **中文语言包**: `MS-CEINTL.vscode-language-pack-zh-hans`
- **Git 增强**: `eamodio.gitlens`
- **代码格式化**: `esbenp.prettier-vscode`
- **ESLint**: `dbaeumer.vscode-eslint`
- **Docker**: `ms-azuretools.vscode-docker`
- **Markdown**: `yzhang.markdown-all-in-one`
- **Go**: `golang.go`
- **Python**: `ms-python.python`

---

## 数据持久化

### 备份

```bash
# 备份配置和数据
tar -czf code-server-backup-$(date +%Y%m%d).tar.gz config/ data/

# 备份工作区
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz workspace/
```

### 恢复

```bash
# 恢复配置和数据
tar -xzf code-server-backup-20261103.tar.gz

# 重启容器
docker-compose restart
```

### 数据迁移

将备份文件传输到新服务器后，解压并启动容器即可。

---

## 高级用法

### 使用 HTTPS

**1. 生成自签名证书**：

```bash
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/code-server.key \
  -out ssl/code-server.crt \
  -subj "/CN=your-domain.com"
```

**2. 修改 `config/config.yaml`**：

```yaml
bind-addr: 0.0.0.0:8888
auth: password
password: your_password
cert: /config/ssl/code-server.crt
cert-key: /config/ssl/code-server.key
```

**3. 挂载证书目录**：

在 `docker-compose.yml` 中添加：

```yaml
volumes:
  - ./config:/root/.config/code-server
  - ./ssl:/config/ssl:ro
```

访问地址改为：`https://localhost:8888`

### 使用 Nginx 反向代理

创建 Nginx 配置：

```nginx
server {
    listen 80;
    server_name code.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name code.example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_http_version 1.1;
        proxy_read_timeout 86400;
    }
}
```

### 自定义工作目录

```yaml
environment:
  - PASSWORD=your_password
  - VSCODE_DEFAULT_WORKSPACE=/workspace/myproject
volumes:
  - /path/to/your/project:/workspace/myproject
```

### 多实例部署

```yaml
services:
  # 实例 1
  code-server-1:
    image: iflyelf/code-server:latest
    container_name: code-server-1
    ports:
      - "8888:8888"
    volumes:
      - ./instance1/config:/root/.config/code-server
      - ./instance1/data:/root/.local/share/code-server
    environment:
      - PASSWORD=password1

  # 实例 2
  code-server-2:
    image: iflyelf/code-server:latest
    container_name: code-server-2
    ports:
      - "8889:8888"
    volumes:
      - ./instance2/config:/root/.config/code-server
      - ./instance2/data:/root/.local/share/code-server
    environment:
      - PASSWORD=password2
```

---

## 故障排查

### 无法访问

```bash
# 检查容器状态
docker ps | grep code-server

# 查看日志
docker logs code-server

# 检查端口
netstat -tlnp | grep 8888

# 测试本地访问
curl -I http://localhost:8888
```

### 密码错误

检查配置文件或环境变量：

```bash
docker exec code-server cat /root/.config/code-server/config.yaml
```

### 界面是英文

**方法 1: 手动切换（最可靠）**

1. 在 Web UI 中按 `F1`
2. 输入 `Configure Display Language`
3. 选择 `中文（简体）`
4. 点击 `Restart` 重新加载

**方法 2: 安装中文语言包**

```bash
docker exec -it code-server code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans
docker-compose restart
```

**方法 3: 清除浏览器缓存**

按 `Ctrl+Shift+Delete` 清除缓存后重新访问。

### 容器无法启动

```bash
# 查看详细日志
docker logs code-server --tail 100

# 检查配置文件格式
cat config/config.yaml

# 检查目录权限
ls -la config/ data/
```

### 扩展无法安装

```bash
# 检查网络连接
docker exec code-server curl -I https://open-vsx.org

# 手动下载扩展并安装
# 1. 从 https://open-vsx.org 下载 .vsix 文件
# 2. 上传到容器
# 3. 安装
docker exec code-server code-server --install-extension /path/to/extension.vsix
```

---

## 构建镜像

### 本地构建

```bash
# 克隆仓库
git clone https://github.com/iflyelf/vscode-docker.git
cd vscode-docker

# 单架构构建
docker build -t code-server:custom .

# 多架构构建
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t iflyelf/code-server:latest \
  --push .
```

### 自定义版本

修改 `Dockerfile` 中的 `CODE_SERVER_VERSION`：

```dockerfile
ARG CODE_SERVER_VERSION=4.144.0
```

重新构建：

```bash
docker build -t code-server:custom .
```

---

## GitHub Actions 配置

本项目使用 GitHub Actions 自动构建和推送镜像。

### 配置 Secrets

在 GitHub 仓库中配置以下 Secrets：

访问：`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

| Secret 名称 | 说明 | 示例值 |
|------------|------|-----|
| `DOCKER_PASSWORD` | Docker Hub 登录密码 | `your_docker_hub_password` |
| `HUAWEI_SWR_PASSWORD` | 华为云 SWR 登录密码 | `your_huawei_swr_password` |

**注意**：请使用您自己的真实密码替换示例值。

### 自动构建触发条件

- **自动触发**：推送代码到 `main` 分支（排除 `.md` 文件和 `.gitignore`）
- **手动触发**：在 Actions 页面点击 `Run workflow`

### 构建功能

- ✅ 自动检测 code-server 最新版本
- ✅ 多架构构建（amd64, arm64）
- ✅ 同时推送到 Docker Hub 和华为云 SWR
- ✅ 自动更新 Dockerfile 和 README 版本号
- ✅ 清理旧的 workflow runs（保留最近 3 次）
- ✅ 构建缓存加速
- ✅ 并发控制（取消旧构建）

### 手动触发构建

**通过 Web 界面**：

访问 https://github.com/iflyelf/vscode-docker/actions，选择工作流并点击 `Run workflow`

**通过 API**：

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/iflyelf/vscode-docker/actions/workflows/docker-publish.yml/dispatches" \
  -d '{"ref":"main"}'
```

### 查看构建状态

访问：https://github.com/iflyelf/vscode-docker/actions

---

## 项目信息

### 版本信息

- **code-server 版本**：v4.144.0
- **基础镜像**：iflyelf/ubuntu:lite
- **支持架构**：linux/amd64, linux/arm64
- **最后更新**：2026-11-03

### 镜像地址

**Docker Hub**：
- `iflyelf/code-server:latest`
- `iflyelf/code-server:4.144.0`

**华为云 SWR（国内推荐）**：
- `swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:latest`
- `swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:4.144.0`

### 项目结构

```
vscode-docker/
├── .github/workflows/
│   └── docker-publish.yml    # GitHub Actions 工作流
├── config/
│   └── config.yaml          # code-server 配置
├── data/User/
│   └── settings.json        # VSCode 配置（带完整注释）
├── workspace/               # 工作区目录
├── .gitignore
├── Dockerfile              # 多阶段构建
├── docker-compose.yml      # Docker Compose 配置
├── deploy.sh               # 一键部署脚本
└── README.md              # 本文档
```

### 技术特点

- **多阶段构建**：构建阶段使用 `iflyelf/ubuntu:latest`，运行阶段使用 `iflyelf/ubuntu:lite`
- **配置挂载**：配置、数据、工作区完全持久化
- **健康检查**：自动检测服务运行状态
- **自动版本跟踪**：GitHub Actions 自动检测并更新最新版本

### 相关链接

- **GitHub**: https://github.com/iflyelf/vscode-docker
- **Docker Hub**: https://hub.docker.com/r/iflyelf/code-server
- **华为云 SWR**: swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server
- **code-server 官方**: https://github.com/coder/code-server
- **基础镜像**: https://github.com/iflyelf/ubuntu-lite
- **配置文档**: /xiaonuo/workspace/doc/VSCode-Web配置指南.md

### 许可证

MIT License

### 贡献

欢迎提交 Issue 和 Pull Request！

### 更新日志

#### v4.144.0 (2026-11-03)
- 初始版本发布
- 基于 code-server v4.144.0
- 支持多架构构建（amd64, arm64）
- 预配置中文界面
- 自动版本跟踪
- 完整的配置文件注释
- GitHub Actions 自动构建

---

## 常见问题

### Q: code-server 和 VSCode Remote 有什么区别？

**A**: 
- **code-server**: 完全基于浏览器，开源，独立部署，任何设备都能访问
- **VSCode Remote**: 官方远程开发工具，需要本地安装 VSCode 客户端

### Q: 可以同时使用多个实例吗？

**A**: 可以，参考[多实例部署](#多实例部署)章节，使用不同端口和配置目录。

### Q: 如何升级 code-server 版本？

**A**: 拉取最新镜像并重新创建容器：

```bash
docker-compose pull
docker-compose up -d
```

配置和数据会自动保留。

### Q: 支持移动设备访问吗？

**A**: 支持，code-server 会自动适配移动浏览器。

### Q: 如何迁移到新服务器？

**A**: 

```bash
# 旧服务器：备份
tar -czf code-server-backup.tar.gz config/ data/ workspace/

# 传输到新服务器
scp code-server-backup.tar.gz new-server:/path/

# 新服务器：解压并启动
tar -xzf code-server-backup.tar.gz
docker-compose up -d
```

### Q: 为什么界面加载很慢？

**A**: 
- 检查网络连接
- 国内用户建议使用华为云 SWR 镜像
- 清除浏览器缓存
- 检查服务器资源使用情况

---

**维护者**: [iflyelf](https://github.com/iflyelf)  
**创建时间**: 2026-11-03  
**项目状态**: ✅ 生产就绪
