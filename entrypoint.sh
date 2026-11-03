#!/bin/bash
set -e

# 扩展目录
EXTENSIONS_DIR="/root/.local/share/code-server/extensions"
EXTENSIONS_BACKUP="/opt/extensions-backup"
CONFIG_FILE="/root/.config/code-server/config.yaml"
USER_DIR="/root/.local/share/code-server/User"
LOCALE_FILE="${USER_DIR}/locale.json"
MACHINE_DIR="/root/.local/share/code-server/Machine"
SETTINGS_FILE="${USER_DIR}/settings.json"

# 如果扩展目录为空或扩展数量少于5个，则从备份恢复
EXTENSION_COUNT=$(ls -A "$EXTENSIONS_DIR" 2>/dev/null | grep -v "extensions.json" | wc -l)
if [ ! -d "$EXTENSIONS_DIR" ] || [ "$EXTENSION_COUNT" -lt 5 ]; then
    echo "检测到扩展目录为空或扩展不完整（当前: ${EXTENSION_COUNT} 个），正在恢复预装扩展..."
    if [ -d "$EXTENSIONS_BACKUP" ]; then
        mkdir -p "$EXTENSIONS_DIR"
        cp -r "$EXTENSIONS_BACKUP"/* "$EXTENSIONS_DIR/" 2>/dev/null || true
        echo "✅ 预装扩展已恢复"
    fi
fi

# 创建必要目录
mkdir -p "$USER_DIR" "$MACHINE_DIR"

# 创建 locale.json 文件（强制设置为中文）
echo "配置中文界面..."
echo '{"locale":"zh-cn"}' > "$LOCALE_FILE"
echo "✅ locale.json 已创建"

# 创建 argv.json（VSCode 的全局语言配置）
ARGV_FILE="${USER_DIR}/argv.json"
echo '{"locale":"zh-cn"}' > "$ARGV_FILE"
echo "✅ argv.json 已创建"

# 使用模板生成 settings.json，支持环境变量替换
if [ ! -f "$SETTINGS_FILE" ] || [ "${FORCE_UPDATE_SETTINGS:-false}" = "true" ]; then
    echo "生成 settings.json..."
    # 从模板复制并替换环境变量
    HTTP_PROXY="${HTTP_PROXY:-}"
    HTTPS_PROXY="${HTTPS_PROXY:-}"
    ALL_PROXY="${ALL_PROXY:-}"
    
    # 使用 envsubst 替换环境变量，如果没有则使用 sed
    if command -v envsubst >/dev/null 2>&1; then
        export HTTP_PROXY HTTPS_PROXY ALL_PROXY
        envsubst < /opt/config-template/settings.json > "$SETTINGS_FILE"
    else
        # 使用 sed 替换
        sed -e "s|\${HTTP_PROXY}|${HTTP_PROXY}|g" \
            -e "s|\${HTTPS_PROXY}|${HTTPS_PROXY}|g" \
            -e "s|\${ALL_PROXY}|${ALL_PROXY}|g" \
            /opt/config-template/settings.json > "$SETTINGS_FILE"
    fi
    echo "✅ settings.json 已生成"
else
    echo "✓ settings.json 已存在，跳过"
fi

# 清除可能导致语言不生效的缓存
echo "清除语言缓存..."
rm -rf /root/.local/share/code-server/CachedExtensionVSIXs/* 2>/dev/null || true
rm -rf /root/.local/share/code-server/logs/* 2>/dev/null || true
echo "✅ 缓存已清除"

# 从环境变量读取配置（提供默认值）
CODE_SERVER_PORT="${CODE_SERVER_PORT:-8888}"
CODE_SERVER_PROXY="${CODE_SERVER_PROXY:-}"

# 生成配置文件
echo "生成 code-server 配置文件..."
cat > "$CONFIG_FILE" << EOF
bind-addr: 0.0.0.0:${CODE_SERVER_PORT}
auth: password
password: ${PASSWORD:-changeme}
cert: false
EOF

# 如果设置了代理，添加到配置文件
if [ -n "$CODE_SERVER_PROXY" ]; then
    echo "proxy-domain: ${CODE_SERVER_PROXY}" >> "$CONFIG_FILE"
    echo "✅ 已配置代理: ${CODE_SERVER_PROXY}"
fi

echo "✅ 配置完成"
echo "   端口: ${CODE_SERVER_PORT}"
echo "   代理: ${CODE_SERVER_PROXY:-未配置}"
echo "   语言: 中文(简体) - 自动配置"
echo "   扩展: 已恢复预装扩展"

# 修改启动命令，使用配置文件而不是命令行参数
if [ "$1" = "/usr/bin/tini" ] && [ "$2" = "--" ] && [ "$3" = "code-server" ]; then
    # 如果是默认的启动命令，使用配置文件启动
    shift 3
    # 使用 --config 明确指定配置文件，让 code-server 读取所有配置
    exec /usr/bin/tini -- code-server --config "${CONFIG_FILE}" "$@"
else
    # 否则执行传入的命令
    exec "$@"
fi
