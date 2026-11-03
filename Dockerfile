#############################
#     设置公共的变量         #
#############################
ARG BASE_IMAGE_TAG=latest
FROM iflyelf/ubuntu:${BASE_IMAGE_TAG} AS builder

# 作者描述信息
LABEL org.opencontainers.image.authors="iflyelf" \
      org.opencontainers.image.vendor="iflyelf" \
      org.opencontainers.image.description="code-server - VSCode Web 远程开发环境"

ARG TARGETARCH
ARG TARGETVARIANT

# code-server 版本
ARG CODE_SERVER_VERSION=4.144.0

# 工作目录
WORKDIR /tmp

# 下载并安装 code-server
RUN set -eux && \
    # 根据架构设置下载 URL
    case "${TARGETARCH}" in \
        amd64) ARCH="amd64" ;; \
        arm64) ARCH="arm64" ;; \
        arm) ARCH="armv7l" ;; \
        *) echo "不支持的架构: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    # 下载 code-server
    CODE_SERVER_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-${ARCH}.tar.gz" && \
    echo "下载 code-server from ${CODE_SERVER_URL}" && \
    curl -fsSL "${CODE_SERVER_URL}" -o code-server.tar.gz && \
    # 解压
    mkdir -p /opt/code-server && \
    tar -xzf code-server.tar.gz -C /opt/code-server --strip-components=1 && \
    # 清理下载文件
    rm -f code-server.tar.gz && \
    # 验证安装
    /opt/code-server/bin/code-server --version

#############################
#     运行阶段             #
#############################
FROM iflyelf/ubuntu:lite

# 作者描述信息
LABEL org.opencontainers.image.authors="iflyelf" \
      org.opencontainers.image.vendor="iflyelf" \
      org.opencontainers.image.description="code-server - VSCode Web 远程开发环境"

ARG TARGETARCH
ARG TARGETVARIANT

# 时区设置
ARG TZ=Asia/Shanghai
ENV TZ=$TZ
# 语言设置
ARG LANG=zh_CN.UTF-8
ENV LANG=$LANG

# 镜像变量
ARG DOCKER_IMAGE=iflyelf/code-server
ENV DOCKER_IMAGE=$DOCKER_IMAGE
ARG DOCKER_IMAGE_OS=ubuntu
ENV DOCKER_IMAGE_OS=$DOCKER_IMAGE_OS
ARG DOCKER_IMAGE_TAG=latest
ENV DOCKER_IMAGE_TAG=$DOCKER_IMAGE_TAG

# code-server 版本
ARG CODE_SERVER_VERSION=4.144.0
ENV CODE_SERVER_VERSION=$CODE_SERVER_VERSION

# 环境设置
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=$DEBIAN_FRONTEND

# code-server 运行时依赖
ARG PKG_DEPS="\
    git \
    openssh-client \
    ca-certificates"
ENV PKG_DEPS=$PKG_DEPS

# 安装运行时依赖
RUN set -eux && \
    # 更新源地址
    sed -i 's@URIs: http://[a-z.]*\.ubuntu\.com/ubuntu/@URIs: https://mirrors.aliyun.com/ubuntu/@g' /etc/apt/sources.list.d/ubuntu.sources && \
    # 解决证书认证失败问题
    touch /etc/apt/apt.conf.d/99verify-peer.conf && echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }" && \
    # 更新系统软件
    DEBIAN_FRONTEND=noninteractive apt update -qqy && \
    # 安装依赖包
    DEBIAN_FRONTEND=noninteractive apt install -qqy --no-install-recommends $PKG_DEPS && \
    # 验证依赖包是否安装成功
    for pkg in $PKG_DEPS; do \
        if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then \
            echo "ERROR: 依赖包未成功安装: $pkg" >&2 && exit 1; \
        fi; \
    done && \
    echo "所有依赖包验证通过" && \
    # 清理
    DEBIAN_FRONTEND=noninteractive apt -qqy autoremove --purge && \
    DEBIAN_FRONTEND=noninteractive apt -qqy autoclean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

# 从构建阶段拷贝 code-server
COPY --from=builder /opt/code-server /opt/code-server

# 创建必要的目录
RUN set -eux && \
    mkdir -p /config /data /root/.local/share/code-server && \
    # 创建符号链接
    ln -sf /opt/code-server/bin/code-server /usr/local/bin/code-server && \
    # 验证安装
    code-server --version

# 安装常用扩展
RUN set -eux && \
    # 中文语言包（必须第一个安装）
    code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans && \
    # GitLens - Git 增强工具
    code-server --install-extension eamodio.gitlens && \
    # Prettier - 代码格式化工具
    code-server --install-extension esbenp.prettier-vscode && \
    # ESLint - JavaScript/TypeScript 代码检查
    code-server --install-extension dbaeumer.vscode-eslint && \
    # Docker 支持
    code-server --install-extension ms-azuretools.vscode-docker && \
    # Go 语言支持
    code-server --install-extension golang.go && \
    # Python 语言支持
    code-server --install-extension ms-python.python && \
    # YAML 语言支持
    code-server --install-extension redhat.vscode-yaml && \
    # 列出已安装的扩展
    code-server --list-extensions && \
    # 备份扩展目录（用于首次启动时恢复）
    mkdir -p /opt/extensions-backup && \
    cp -r /root/.local/share/code-server/extensions/* /opt/extensions-backup/

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 设置 PATH
ENV PATH="/opt/code-server/bin:${PATH}"

# 暴露端口
EXPOSE 8888

# 工作目录
WORKDIR /root

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8888/ || exit 1

# 使用自定义 entrypoint（包含扩展恢复逻辑）
ENTRYPOINT ["/entrypoint.sh"]

# 启动 code-server
CMD ["/usr/bin/tini", "--", "code-server", "--bind-addr", "0.0.0.0:8888", "--auth", "password"]
