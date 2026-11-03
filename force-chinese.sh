#!/bin/bash
# 强制切换到中文界面的脚本

echo "=== 强制配置中文界面 ==="
echo ""

# 停止容器
echo "1. 停止容器..."
docker-compose down

# 清理所有可能的缓存
echo "2. 清理缓存..."
rm -rf data/CachedExtensionVSIXs/*
rm -rf data/CachedProfilesData/*
rm -rf data/logs/*
rm -rf data/coder-logs/*
rm -f data/coder.json
rm -f data/languagepacks.json

# 强制重新创建配置文件
echo "3. 重新创建配置文件..."
mkdir -p data/User

cat > data/User/locale.json << 'LOCALE_EOF'
{"locale":"zh-cn"}
LOCALE_EOF

cat > data/User/argv.json << 'ARGV_EOF'
{"locale":"zh-cn"}
ARGV_EOF

# 启动容器
echo "4. 启动容器（使用强制更新配置）..."
export FORCE_UPDATE_SETTINGS=true
docker-compose up -d

echo ""
echo "✅ 配置完成！"
echo ""
echo "请执行以下操作："
echo "1. 等待 10 秒让容器完全启动"
echo "2. 关闭浏览器所有标签"
echo "3. 清除浏览器缓存（Ctrl + Shift + Delete）"
echo "4. 或使用隐私模式访问: http://localhost:8888"
echo ""
echo "如果还是英文，可能需要在界面中手动选择一次中文："
echo "  按 F1 → 输入 configure display language → 选择中文"
