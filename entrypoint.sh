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

# 如果扩展目录为空或只有 extensions.json，则从备份恢复
if [ ! -d "$EXTENSIONS_DIR" ] || [ "$(ls -A "$EXTENSIONS_DIR" | wc -l)" -le 1 ]; then
    echo "检测到扩展目录为空，正在恢复预装扩展..."
    if [ -d "$EXTENSIONS_BACKUP" ]; then
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

# 创建或更新 settings.json，确保包含 locale 配置
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "创建 settings.json..."
    cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
    "locale": "zh-cn",
    "workbench.colorTheme": "Default Dark+",
    "editor.fontSize": 14,
    "editor.tabSize": 4
}
SETTINGS_EOF
else
    # 如果 settings.json 存在，确保包含 locale 配置
    if ! grep -q '"locale"' "$SETTINGS_FILE"; then
        echo "更新 settings.json 添加 locale 配置..."
        # 在第一个 { 后面插入 locale 配置
        sed -i '1 a\    "locale": "zh-cn",' "$SETTINGS_FILE"
    fi
fi
echo "✅ settings.json 已配置"

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

# 修改启动命令中的端口
if [ "$1" = "/usr/bin/tini" ] && [ "$2" = "--" ] && [ "$3" = "code-server" ]; then
    # 如果是默认的启动命令，替换端口参数
    shift 3
    exec /usr/bin/tini -- code-server --bind-addr "0.0.0.0:${CODE_SERVER_PORT}" --auth password "$@"
else
    # 否则执行传入的命令
    exec "$@"
fi
