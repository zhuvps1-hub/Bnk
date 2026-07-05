# Bnk - TCP/UDP Traffic Forwarding Tool

[![Go Report Card](https://goreportcard.com/badge/github.com/zhuvps1-hub/Bnk)](https://goreportcard.com/report/github.com/zhuvps1-hub/Bnk)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/zhuvps1-hub/Bnk?style=flat)](https://github.com/zhuvps1-hub/Bnk/releases)

一个高性能的 TCP/UDP 流量转发工具，用 Go 语言编写。支持多协议转发、一键安装下载、跨平台支持。

[English](./README.en.md) | [中文](./README.md)

## ✨ 核心功能

- 🚀 **高性能转发** - 基于 Go goroutine 的并发处理，支持高并发连接
- 🔄 **双向协议支持** - TCP 和 UDP 全覆盖
- ⚙️ **灵活配置** - 支持 YAML 配置，轻松管理多个转发规则
- 🖥️ **跨平台支持** - Windows、macOS、Linux 完全支持
- 📦 **一键安装** - 预编译二进制文件下载即用
- 📊 **详细日志** - 实时显示转发信息和错误日志
- 🔌 **多端口转发** - 支持同时运行多个转发规则
- 🛑 **优雅关闭** - Ctrl+C 安全退出，自动清理资源

## 📋 应用场景

- **内网穿透** - 转发内网服务到外网端口
- **负载均衡** - 将流量转发到多个后端服务
- **DNS 转发** - 自定义 DNS 服务器
- **SSH 转发** - 转发 SSH 连接到远程主机
- **代理转发** - 创建临时代理服务
- **局域网共享** - 共享本地服务到其他机器
- **协议转换** - 转发不同网络间的流量

## 🚀 快速开始

### 🐧 Linux 一键安装（推荐）⭐

最简单的安装方式，一条命令完成所有配置：

```bash
curl -fsSL https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/install.sh | bash
```

或使用 wget：

```bash
wget -q -O - https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/install.sh | bash
```

**安装脚本会自动：**
- ✅ 检测系统架构（x86_64/ARM64）
- ✅ 下载最新版本
- ✅ 安装到 `/usr/local/bin`
- ✅ 创建配置文件
- ✅ 可选创建 Systemd 服务
- ✅ 可选开机自启

详见 [Linux 安装指南](./INSTALL.md)

### 方式一：下载预编译二进制

从 [Release](https://github.com/zhuvps1-hub/Bnk/releases) 页面下载对应平台的预编译文件：

**Linux/macOS:**
```bash
# 下载后解压或直接使用
chmod +x bnk
./bnk -config config.yaml
```

**Windows:**
```bash
# 下载后直接双击或命令行运行
bnk.exe -config config.yaml
```

### 方式二：从源码编译

需要安装 [Go 1.16+](https://golang.org/dl/)

```bash
# 克隆仓库
git clone https://github.com/zhuvps1-hub/Bnk.git
cd Bnk

# 编译
make build

# 运行
./bin/bnk -config config.yaml
```

### 方式三：编译所有平台版本

```bash
make build-all

# 编译后的文件在 dist/ 目录
ls dist/
# bnk-linux-amd64  bnk-linux-arm64  bnk-darwin-amd64  bnk-darwin-arm64  bnk-windows-amd64.exe
```

## 📖 配置教程

### 基础配置

创建 `config.yaml` 文件：

```yaml
forwards:
  - name: "http_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "example.com:80"
  
  - name: "dns_forward"
    protocol: "udp"
    listen: "0.0.0.0:5353"
    target: "8.8.8.8:53"
```

### 配置参数说明

| 参数 | 必需 | 说明 | 示例 |
|------|------|------|------|
| name | ✅ | 转发规则的唯一名称 | http_forward |
| protocol | ✅ | 协议类型，支持 tcp/udp | tcp |
| listen | ✅ | 本地监听地址和端口 | 0.0.0.0:8080 |
| target | ✅ | 目标服务器地址和端口 | example.com:80 |

## 💡 使用示例

### 示例 1：HTTP 服务转发

**场景**：将本地 8080 端口转发到远程服务器的 80 端口

```yaml
forwards:
  - name: "http_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "192.168.1.100:80"
```

**使用**：
```bash
./bnk -config config.yaml
# 访问 http://localhost:8080 等同于访问 http://192.168.1.100:80
```

### 示例 2：SSH 远程登录

**场景**：转发 SSH 连接到内网主机

```yaml
forwards:
  - name: "ssh_forward"
    protocol: "tcp"
    listen: "0.0.0.0:2222"
    target: "192.168.1.10:22"
```

**使用**：
```bash
./bnk -config config.yaml
# SSH 连接
ssh -p 2222 user@localhost
```

### 示例 3：DNS 查询转发

**场景**：自定义 DNS 服务器

```yaml
forwards:
  - name: "dns_forward"
    protocol: "udp"
    listen: "0.0.0.0:5353"
    target: "8.8.8.8:53"
```

**使用**：
```bash
./bnk -config config.yaml
# 设置系统 DNS 为 localhost:5353
nslookup example.com localhost
```

### 示例 4：多个转发规则

**场景**：同时运行多个转发服务

```yaml
forwards:
  # HTTP 转发
  - name: "http_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "192.168.1.1:80"

  # HTTPS 转发
  - name: "https_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8443"
    target: "192.168.1.1:443"

  # DNS 转发
  - name: "dns_forward"
    protocol: "udp"
    listen: "0.0.0.0:5353"
    target: "8.8.8.8:53"

  # SSH 转发
  - name: "ssh_forward"
    protocol: "tcp"
    listen: "0.0.0.0:2222"
    target: "192.168.1.10:22"

  # NTP 转发
  - name: "ntp_forward"
    protocol: "udp"
    listen: "0.0.0.0:9123"
    target: "pool.ntp.org:123"
```

**使用**：
```bash
./bnk -config config.yaml
# 所有转发规则同时工作
```

### 示例 5：内网穿透

**场景**：将内网服务暴露到公网

```yaml
forwards:
  - name: "web_service"
    protocol: "tcp"
    listen: "0.0.0.0:8000"
    target: "192.168.1.50:3000"
```

**使用**：
```bash
# 在公网服务器上运行 Bnk
./bnk -config config.yaml

# 公网用户访问
# http://your-public-ip:8000 -> 内网 192.168.1.50:3000 服务
```

## 🎯 实际应用案例

### 案例 1：开发环境本地转发

```yaml
forwards:
  # 本地开发 Web 服务
  - name: "dev_web"
    protocol: "tcp"
    listen: "0.0.0.0:3000"
    target: "127.0.0.1:8000"

  # 本地开发数据库
  - name: "dev_db"
    protocol: "tcp"
    listen: "0.0.0.0:3306"
    target: "127.0.0.1:5432"
```

### 案例 2：公司内网服务访问

```yaml
forwards:
  # 转发公司内网 Wiki
  - name: "company_wiki"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "wiki.company.local:80"

  # 转发公司内网 GitLab
  - name: "company_gitlab"
    protocol: "tcp"
    listen: "0.0.0.0:8443"
    target: "gitlab.company.local:443"
```

### 案例 3：多服务器负载均衡

```yaml
forwards:
  # 主服务器
  - name: "main_service"
    protocol: "tcp"
    listen: "0.0.0.0:80"
    target: "server1.example.com:80"

  # 备份转发
  - name: "backup_service"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "server2.example.com:80"
```

## 🔧 命令行选项

```bash
# 基本用法
./bnk -config config.yaml

# 使用自定义配置文件路径
./bnk -config /path/to/config.yaml

# 显示帮助
./bnk -h
```

## 📊 日志输出示例

```
2024-01-15T10:30:45.123Z	INFO	Starting Bnk v1.0.0
2024-01-15T10:30:45.125Z	INFO	Config file: config.yaml
2024-01-15T10:30:45.126Z	INFO	Loaded 4 forward rules
2024-01-15T10:30:45.127Z	INFO	Added forward rule: http_forward (tcp) 0.0.0.0:8080 -> 192.168.1.1:80
2024-01-15T10:30:45.128Z	INFO	Added forward rule: dns_forward (udp) 0.0.0.0:5353 -> 8.8.8.8:53
2024-01-15T10:30:45.129Z	INFO	Added forward rule: ssh_forward (tcp) 0.0.0.0:2222 -> 192.168.1.10:22
2024-01-15T10:30:45.130Z	INFO	Added forward rule: ntp_forward (udp) 0.0.0.0:9123 -> pool.ntp.org:123
2024-01-15T10:30:45.131Z	INFO	Bnk is running...
```

## 🛠️ 编译与部署

### 使用 Makefile

```bash
# 编译当前平台
make build

# 编译所有平台
make build-all

# 清理构建文件
make clean

# 显示帮助
make help
```

### 手动编译

```bash
# 编译 Linux 64位
GOOS=linux GOARCH=amd64 go build -o bnk-linux-amd64 ./cmd/main.go

# 编译 macOS Intel
GOOS=darwin GOARCH=amd64 go build -o bnk-darwin-amd64 ./cmd/main.go

# 编译 macOS ARM
GOOS=darwin GOARCH=arm64 go build -o bnk-darwin-arm64 ./cmd/main.go

# 编译 Windows
GOOS=windows GOARCH=amd64 go build -o bnk-windows-amd64.exe ./cmd/main.go
```

## 📦 系统要求

- **Go 版本**：1.16+ （仅编译时需要）
- **运行环境**：Linux、macOS、Windows
- **内存**：≥ 50MB
- **CPU**：无特殊要求
- **端口权限**：需要能够监听指定端口（< 1024 的端口需要管理员权限）

## ⚙️ 性能指标

- **单连接延迟**：< 1ms
- **并发连接数**：> 10,000
- **吞吐量**：> 1Gbps
- **内存占用**：~ 50MB（基础）+ 转发规则数

## 🔒 安全注意事项

1. **权限控制**：不要以过高权限运行
2. **防火墙**：根据需要配置防火墙规则
3. **监听地址**：避免绑定 `0.0.0.0` 到不信任的网络
4. **日志检查**：定期查看日志找出异常流量
5. **配置保护**：保护好 `config.yaml` 文件中的敏感信息

## 🐛 故障排除

### 问题 1：端口已被占用

```
Failed to listen on 0.0.0.0:8080: listen tcp 0.0.0.0:8080: bind: address already in use
```

**解决方案**：
```bash
# Linux/macOS 查看占用端口的进程
lsof -i :8080

# Windows 查看占用端口的进程
netstat -ano | findstr :8080

# 修改配置中的端口或关闭占用端口的程序
```

### 问题 2：目标服务器无法连接

```
Failed to connect to target 192.168.1.1:80: dial tcp 192.168.1.1:80: i/o timeout
```

**解决方案**：
- 检查目标地址和端口是否正确
- 检查网络连通性：`ping 192.168.1.1`
- 检查防火墙规则
- 确保目标服务器已启动

### 问题 3：权限不足

```
listen tcp :80: bind: permission denied
```

**解决方案**：
```bash
# Linux/macOS 使用 sudo
sudo ./bnk -config config.yaml

# 或使用更高的端口号（> 1024）
```

## 📝 配置最佳实践

### 1. 使用描述性的规则名称

```yaml
forwards:
  - name: "intranet_web_service"  # ✅ 好
    # - name: "fwd1"               # ❌ 不好
```

### 2. 明确指定监听地址

```yaml
forwards:
  - name: "secure_forward"
    protocol: "tcp"
    listen: "127.0.0.1:8080"  # ✅ 只本地访问
    # listen: "0.0.0.0:8080" # ⚠️ 任何 IP 都可访问
```

### 3. 验证目标服务

```yaml
forwards:
  - name: "service_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "192.168.1.100:80"  # ✅ 验证此服务是否在线
```

## 🚀 高级功能

### 创建 Systemd 服务（Linux）

创建文件 `/etc/systemd/system/bnk.service`：

```ini
[Unit]
Description=Bnk Traffic Forwarding Tool
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/bnk
ExecStart=/opt/bnk/bnk -config /opt/bnk/config.yaml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl start bnk
sudo systemctl enable bnk
sudo systemctl status bnk
```

### Docker 部署

创建 `Dockerfile`：

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o bnk ./cmd/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/bnk /usr/local/bin/

ENTRYPOINT ["bnk", "-config", "/etc/bnk/config.yaml"]
```

构建和运行：
```bash
docker build -t bnk .
docker run -d --name bnk -p 8080:8080 -p 5353:5353/udp \
  -v $(pwd)/config.yaml:/etc/bnk/config.yaml \
  bnk
```

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

- **Issue 反馈**：[GitHub Issues](https://github.com/zhuvps1-hub/Bnk/issues)
- **讨论区**：[GitHub Discussions](https://github.com/zhuvps1-hub/Bnk/discussions)
- **安装指南**：[Linux 一键安装](./INSTALL.md)

## 👤 作者

Maintained by [zhuvps1-hub](https://github.com/zhuvps1-hub)

---

**快速开始**：[下载最新版本](https://github.com/zhuvps1-hub/Bnk/releases) | [查看配置示例](./example-config.yaml) | [Linux 一键安装](./INSTALL.md)
