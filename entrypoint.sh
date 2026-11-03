#!/bin/bash
set -e

# 扩展目录
EXTENSIONS_DIR="/root/.local/share/code-server/extensions"
EXTENSIONS_BACKUP="/opt/extensions-backup"

# 如果扩展目录为空或只有 extensions.json，则从备份恢复
if [ ! -d "$EXTENSIONS_DIR" ] || [ "$(ls -A "$EXTENSIONS_DIR" | wc -l)" -le 1 ]; then
    echo "检测到扩展目录为空，正在恢复预装扩展..."
    if [ -d "$EXTENSIONS_BACKUP" ]; then
        cp -r "$EXTENSIONS_BACKUP"/* "$EXTENSIONS_DIR/" 2>/dev/null || true
        echo "✅ 预装扩展已恢复"
    fi
fi

# 执行传入的命令
exec "$@"
