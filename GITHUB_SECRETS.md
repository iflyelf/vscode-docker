# GitHub Secrets 配置说明

在使用 GitHub Actions 自动构建前，需要在 GitHub 仓库中配置以下 Secrets。

## 配置步骤

1. 打开 GitHub 仓库页面
2. 点击 `Settings` -> `Secrets and variables` -> `Actions`
3. 点击 `New repository secret` 添加以下 Secrets

## 必需的 Secrets

### 1. DOCKER_PASSWORD

**说明**: Docker Hub 登录密码

**值**: 
```
ysyh!9Sky
```

**用途**: 用于登录 Docker Hub 并推送镜像

---

### 2. HUAWEI_SWR_PASSWORD

**说明**: 华为云 SWR 登录密码

**值**:
```
89859da8eda4ca25a0d0e6012c798c479ff11634b41d0b99abb08fead6ec1af6
```

**用途**: 用于登录华为云 SWR 并推送镜像

---

## 验证配置

配置完成后，可以手动触发 workflow 验证：

```bash
# 使用 GitHub CLI
gh workflow run docker-publish.yml

# 或通过 API
curl -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/iflyelf/vscode-docker/actions/workflows/docker-publish.yml/dispatches" \
  -d '{"ref":"main"}'
```

## 查看构建状态

访问以下地址查看构建状态：

https://github.com/iflyelf/vscode-docker/actions

## 镜像推送地址

构建成功后，镜像会推送到：

1. **Docker Hub**: 
   - `iflyelf/code-server:latest`
   - `iflyelf/code-server:4.144.0`

2. **华为云 SWR**:
   - `swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:latest`
   - `swr.cn-east-3.myhuaweicloud.com/iflyelf/code-server:4.144.0`

## 触发构建的条件

1. **自动触发**:
   - 推送代码到 `main` 分支
   - 排除 `.md` 文件和 `.gitignore` 的变更

2. **手动触发**:
   - 在 GitHub Actions 页面点击 `Run workflow`

## 构建功能

1. ✅ 自动检测 code-server 最新版本
2. ✅ 多架构构建 (amd64, arm64)
3. ✅ 同时推送到 Docker Hub 和华为云 SWR
4. ✅ 自动更新 Dockerfile 和 README 中的版本号
5. ✅ 自动清理旧的 workflow runs（保留最近 3 次）
6. ✅ 构建缓存加速

## 故障排查

### 问题 1: Secrets 未配置

**错误信息**: `Error: Username and password required`

**解决方案**: 确保已在 GitHub 仓库中配置 `DOCKER_PASSWORD` 和 `HUAWEI_SWR_PASSWORD`

### 问题 2: 权限不足

**错误信息**: `Resource not accessible by integration`

**解决方案**: 检查 workflow 文件中的 `permissions` 配置

### 问题 3: 构建超时

**解决方案**: 
- 检查网络连接
- 多架构构建需要较长时间，属于正常现象
- GitHub Actions 免费版单次构建限制 6 小时

## 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com)
- [华为云 SWR](https://www.huaweicloud.com/product/swr.html)
