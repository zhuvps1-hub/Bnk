# Linux 一键安装指南

## 📦 快速安装

### 方法一：使用安装脚本（推荐）⭐

最简单的方式，一条命令完成安装：

```bash
curl -fsSL https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/install.sh | bash
```

或者

```bash
wget -q -O - https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/install.sh | bash
```

### 方法二：分步安装

#### 1. 下载安装脚本

```bash
# 使用 curl
curl -fsSL -O https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/install.sh

# 或使用 wget
wget https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/install.sh
```

#### 2. 赋予执行权限

```bash
chmod +x install.sh
```

#### 3. 运行安装脚本

```bash
sudo ./install.sh
```

或直接运行（会提示需要 sudo）

```bash
./install.sh
```

## 🔧 安装脚本功能

安装脚本会自动完成以下操作：

✅ **系统检测** - 识别 OS 和 CPU 架构（x86_64/ARM64）
✅ **版本检查** - 获取最新发布版本
✅ **二进制下载** - 从 GitHub Release 下载
✅ **二进制安装** - 安装到 `/usr/local/bin`
✅ **配置初始化** - 创建 `/etc/bnk` 目录和示例配置
✅ **Systemd 服务** - 可选创建 systemd 服务文件
✅ **自动启动** - 可选设置开机自启

## 📋 安装后的文件位置

```
/usr/local/bin/bnk              # 可执行文件
/etc/bnk/config.yaml            # 配置文件
/etc/systemd/system/bnk.service # Systemd 服务文件（可选）
```

## 🚀 使用

### 查看帮助

```bash
bnk -h
```

### 运行转发

```bash
bnk -config /etc/bnk/config.yaml
```

### 使用 Systemd 服务（如果已创建）

```bash
# 启动服务
sudo systemctl start bnk

# 停止服务
sudo systemctl stop bnk

# 查看状态
sudo systemctl status bnk

# 查看日志
sudo journalctl -u bnk -f

# 开机自启
sudo systemctl enable bnk
```

## ⚙️ 配置编辑

安装后，编辑配置文件：

```bash
sudo nano /etc/bnk/config.yaml
```

配置文件示例：

```yaml
forwards:
  - name: "http_forward"
    protocol: "tcp"
    listen: "0.0.0.0:8080"
    target: "192.168.1.1:80"

  - name: "dns_forward"
    protocol: "udp"
    listen: "0.0.0.0:5353"
    target: "8.8.8.8:53"
```

编辑后重启服务：

```bash
sudo systemctl restart bnk
```

## 🗑️ 卸载

### 使用卸载脚本

```bash
# 下载卸载脚本
curl -fsSL -O https://raw.githubusercontent.com/zhuvps1-hub/Bnk/main/uninstall.sh

# 赋予执行权限
chmod +x uninstall.sh

# 运行卸载
sudo ./uninstall.sh
```

### 手动卸载

```bash
# 停止服务
sudo systemctl stop bnk
sudo systemctl disable bnk

# 移除文件
sudo rm -f /usr/local/bin/bnk
sudo rm -f /etc/systemd/system/bnk.service

# 重新加载 systemd
sudo systemctl daemon-reload

# 可选：删除配置目录
sudo rm -rf /etc/bnk
```

## 🐛 故障排除

### 问题 1：权限被拒绝

```
permission denied
```

**解决方案**：使用 `sudo` 运行脚本

```bash
sudo ./install.sh
```

### 问题 2：无法下载二进制文件

```
Failed to download binary
```

**可能原因**：
- 网络连接问题
- GitHub 无法访问（可能需要翻墙）

**解决方案**：
- 检查网络连接
- 尝试使用代理或 VPN
- 手动从 [Release](https://github.com/zhuvps1-hub/Bnk/releases) 页面下载

### 问题 3：无法获取最新版本

```
Failed to fetch latest version
```

**可能原因**：API 速率限制或网络问题

**解决方案**：
- 稍后重试
- 检查 GitHub 是否可访问

### 问题 4：systemd 服务启动失败

查看详细错误日志：

```bash
sudo journalctl -u bnk -n 50
```

常见原因：
- 配置文件路径错误
- 配置文件格式错误
- 监听端口被占用

## 📊 验证安装

安装完成后，验证：

```bash
# 查看版本
bnk -h

# 测试配置
bnk -config /etc/bnk/config.yaml

# 查看服务状态（如果已创建服务）
sudo systemctl status bnk
```

## 🔒 安全建议

1. **定期更新**：定期运行安装脚本以获取最新版本
2. **配置保护**：保护 `/etc/bnk/config.yaml` 的访问权限
3. **日志监控**：定期检查日志找出异常
4. **防火墙配置**：根据需要配置防火墙规则

## 📝 系统支持

已测试支持的系统：

- ✅ Ubuntu 18.04+
- ✅ Debian 9+
- ✅ CentOS 7+
- ✅ RHEL 7+
- ✅ Fedora 30+
- ✅ Alpine Linux
- ✅ Raspberry Pi OS (ARM64)

## 🤝 需要帮助？

- 📖 [完整文档](../README.md)
- 🐛 [报告问题](https://github.com/zhuvps1-hub/Bnk/issues)
- 💬 [讨论区](https://github.com/zhuvps1-hub/Bnk/discussions)

## 📜 许可证

MIT License - 详见 [LICENSE](../LICENSE)
