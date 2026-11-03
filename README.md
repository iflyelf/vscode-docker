# code-server Docker 镜像

[![Docker Image](https://img.shields.io/badge/docker-iflyelf%2Fcode--server-blue)](https://hub.docker.com/r/iflyelf/code-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/iflyelf/code-server)](https://hub.docker.com/r/iflyelf/code-server)
[![Docker Image Size](https://img.shields.io/docker/image-size/iflyelf/code-server/latest)](https://hub.docker.com/r/iflyelf/code-server)
[![GitHub](https://img.shields.io/github/license/iflyelf/vscode-docker)](https://github.com/iflyelf/vscode-docker)

基于 Ubuntu 的 code-server Docker 镜像，提供完整的 VSCode Web 开发环境。

## 特性

- ✅ 基于 `iflyelf/ubuntu:lite` 精简镜像
- ✅ 多阶段构建，镜像体积更小
- ✅ 支持多架构：`linux/amd64`, `linux/arm64`
- ✅ 预配置中文界面
- ✅ 自动跟踪 code-server 最新版本
- ✅ 配置文件和数据目录挂载
- ✅ 健康检查
- ✅ 使用 tini 作为 init 进程

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

### 使用 Docker 命令

```bash
docker run -d \
  --name code-server \
  -p 8888:8888 \
  -v $(pwd)/config:/root/.config/code-server \
  -v $(pwd)/data:/root/.local/share/code-server \
  -v $(pwd)/workspace:/workspace \
  -e PASSWORD=ysyh!9Sky \
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
  -e PASSWORD=ysyh!9Sky \
  --restart always \
  swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:latest
```

## 访问

打开浏览器访问：

```
http://localhost:8888
```

默认密码：`ysyh!9Sky`

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
password: ysyh!9Sky
cert: false
```

**data/User/settings.json**：

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

### 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `PASSWORD` | 登录密码 | - |
| `TZ` | 时区 | `Asia/Shanghai` |
| `LANG` | 语言 | `zh_CN.UTF-8` |

## 版本信息

- **code-server 版本**：v4.144.0
- **基础镜像**：iflyelf/ubuntu:lite
- **最后更新**：2026-11-03

## 扩展安装

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
```

批量安装：

```bash
docker exec -it code-server /bin/zsh -c "cat /workspace/extensions.txt | xargs -L 1 code-server --install-extension"
```

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

## 高级用法

### 使用 HTTPS

1. 准备 SSL 证书
2. 修改 `config/config.yaml`：

```yaml
bind-addr: 0.0.0.0:8888
auth: password
password: ysyh!9Sky
cert: /config/ssl/cert.pem
cert-key: /config/ssl/key.pem
```

3. 挂载证书目录：

```yaml
volumes:
  - ./config:/root/.config/code-server
  - ./ssl:/config/ssl:ro
```

### 自定义工作目录

```yaml
environment:
  - PASSWORD=ysyh!9Sky
  - VSCODE_DEFAULT_WORKSPACE=/workspace/myproject
volumes:
  - /path/to/your/project:/workspace/myproject
```

### 多实例部署

```yaml
# 实例 1
code-server-1:
  image: iflyelf/code-server:latest
  ports:
    - "8888:8888"
  volumes:
    - ./instance1/config:/root/.config/code-server
    - ./instance1/data:/root/.local/share/code-server

# 实例 2
code-server-2:
  image: iflyelf/code-server:latest
  ports:
    - "8889:8888"
  volumes:
    - ./instance2/config:/root/.config/code-server
    - ./instance2/data:/root/.local/share/code-server
```

## 故障排查

### 无法访问

```bash
# 检查容器状态
docker ps | grep code-server

# 查看日志
docker logs code-server

# 检查端口
netstat -tlnp | grep 8888
```

### 密码错误

检查配置文件或环境变量：

```bash
docker exec code-server cat /root/.config/code-server/config.yaml
```

### 界面是英文

1. 安装中文语言包
2. 在 Web UI 中按 `F1`，输入 `Configure Display Language`，选择中文

## 构建镜像

### 本地构建

```bash
# 克隆仓库
git clone https://github.com/iflyelf/vscode-docker.git
cd vscode-docker

# 构建镜像
docker build -t code-server:custom .

# 多架构构建
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t iflyelf/code-server:latest \
  --push .
```

### GitHub Actions 自动构建

推送到 `main` 分支会自动触发构建：

- ✅ 自动检测 code-server 最新版本
- ✅ 多架构构建（amd64, arm64）
- ✅ 同时推送到 Docker Hub 和华为云 SWR
- ✅ 自动更新版本号和文档

## 相关链接

- **Docker Hub**: https://hub.docker.com/r/iflyelf/code-server
- **华为云 SWR**: swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server
- **GitHub**: https://github.com/iflyelf/vscode-docker
- **code-server 官方**: https://github.com/coder/code-server
- **基础镜像**: https://github.com/iflyelf/ubuntu-lite

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v4.144.0 (2026-11-03)
- 初始版本发布
- 基于 code-server v4.144.0
- 支持多架构构建
- 预配置中文界面
- 自动版本跟踪

---

**维护者**: [iflyelf](https://github.com/iflyelf)
