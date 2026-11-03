#!/bin/bash
# code-server Docker 部署脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo_error "Docker 未安装"
    exit 1
fi

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo_error "Docker Compose 未安装"
    exit 1
fi

# 创建必要的目录
echo_info "创建必要的目录..."
mkdir -p config data/User workspace

# 创建默认配置文件
if [ ! -f "config/config.yaml" ]; then
    echo_info "创建默认配置文件..."
    cat > config/config.yaml << 'EOF'
bind-addr: 0.0.0.0:8888
auth: password
password: ysyh!9Sky
cert: false
EOF
fi

# 创建默认用户设置
if [ ! -f "data/User/settings.json" ]; then
    echo_info "创建默认用户设置..."
    cat > data/User/settings.json << 'EOF'
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
EOF
fi

# 拉取镜像
echo_info "拉取 code-server 镜像..."
docker-compose pull

# 启动服务
echo_info "启动 code-server 服务..."
docker-compose up -d

# 等待服务启动
echo_info "等待服务启动..."
sleep 5

# 检查服务状态
if docker-compose ps | grep -q "Up"; then
    echo_info "code-server 启动成功！"
    echo ""
    echo "========================================"
    echo "访问地址: http://localhost:8888"
    echo "默认密码: ysyh!9Sky"
    echo "========================================"
    echo ""
    echo "查看日志: docker-compose logs -f"
    echo "停止服务: docker-compose down"
    echo "重启服务: docker-compose restart"
else
    echo_error "服务启动失败，请查看日志："
    docker-compose logs
    exit 1
fi
