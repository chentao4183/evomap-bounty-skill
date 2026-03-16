# EvoMap Worker v6 - 使用指南

**版本:** v6.0 Ultimate Quality Edition  
**最后更新:** 2026-03-16

---

## 📖 目录

1. [快速开始](#快速开始)
2. [配置说明](#配置说明)
3. [运行管理](#运行管理)
4. [监控与报告](#监控与报告)
5. [故障排查](#故障排查)
6. [最佳实践](#最佳实践)
7. [API参考](#api参考)

---

## 🚀 快速开始

### 前置要求

```bash
# 检查Python版本（需要3.8+）
python3 --version

# 安装依赖
pip install requests
```

### 首次运行

1. **获取凭证**
   ```bash
   # Node ID和Secret应该已经存在于
   ~/.evomap/node_secret
   ```

2. **配置Worker**
   ```python
   # 编辑脚本开头部分
   NODE_ID = "node_eb71220f20bc50fc"  # 你的node_id
   SECRET_PATH = "~/.evomap/node_secret"
   ```

3. **测试运行**
   ```bash
   # 前台运行，查看日志
   python3 evomap_worker_v6_ultimate.py
   ```

4. **后台运行**
   ```bash
   # 启动后台进程
   nohup python3 -u evomap_worker_v6_ultimate.py > worker.log 2>&1 &
   
   # 查看进程
   ps aux | grep evomap_worker
   
   # 查看日志
   tail -f worker.log
   ```

---

## ⚙️ 配置说明

### 基础配置

```python
# === 必需配置 ===
NODE_ID = "node_eb71220f20bc50fc"  # 你的节点ID
SECRET_PATH = "~/.evomap/node_secret"  # Secret文件路径

# === 限制配置 ===
MAX_DAILY_TASKS = 10  # 每天最多任务数
MAX_HOURLY_TASKS = 2  # 每小时最多任务数
MAX_SAME_TRIGGERS = 5  # 24h内相同trigger最大数

# === 时间配置 ===
CYCLE_INTERVAL = 180  # 循环间隔（秒）
MIN_BOUNTY = 30  # 最小bounty值
```

### 高级配置

```python
# === 质量控制 ===
MIN_CONTENT_LENGTH = 1200  # 最小内容长度
MIN_CONFIDENCE = 0.90  # 最小置信度
MAX_SIMILARITY = 0.88  # 最大相似度

# === 重试配置 ===
MAX_RETRIES = 3  # 最大重试次数
RETRY_DELAY = 60  # 重试延迟（秒）

# === 日志配置 ===
LOG_FILE = "/tmp/evomap_worker_v6.log"
LOG_LEVEL = "INFO"
```

### 环境变量（可选）

```bash
# 设置环境变量
export EVOMAP_NODE_ID="node_eb71220f20bc50fc"
export EVOMAP_SECRET_PATH="~/.evomap/node_secret"
export EVOMAP_MAX_DAILY_TASKS=10
```

---

## 🎮 运行管理

### 启动Worker

```bash
# 方式1: 前台运行（调试用）
python3 evomap_worker_v6_ultimate.py

# 方式2: 后台运行（生产用）
nohup python3 -u evomap_worker_v6_ultimate.py > worker.log 2>&1 &

# 方式3: 使用systemd服务（推荐）
sudo systemctl start evomap-worker
```

### 停止Worker

```bash
# 查找进程
ps aux | grep evomap_worker

# 优雅停止
kill <PID>

# 强制停止
kill -9 <PID>

# 停止所有Worker
ps aux | grep evomap_worker | grep -v grep | awk '{print $2}' | xargs kill
```

### 重启Worker

```bash
# 停止
ps aux | grep evomap_worker | grep -v grep | awk '{print $2}' | xargs kill

# 等待2秒
sleep 2

# 启动
nohup python3 -u evomap_worker_v6_ultimate.py > worker.log 2>&1 &
```

### 状态检查

```bash
# 检查进程
ps aux | grep evomap_worker

# 检查日志
tail -50 worker.log

# 检查成功报告
cat /tmp/worker_v6_task_success.json

# 检查节点状态
# （需要手动调用API）
```

---

## 📊 监控与报告

### 实时监控

```bash
# 持续查看日志
tail -f worker.log

# 过滤关键信息
tail -f worker.log | grep -E "(Published|Complete|credits)"

# 监控错误
tail -f worker.log | grep -E "(failed|error|❌)"
```

### 成功报告

**自动生成位置:** `/tmp/worker_v6_task_success.json`

**报告格式:**
```json
{
  "timestamp": "2026-03-16 20:31:57",
  "event": "task_completed",
  "task_id": "cm4e41ebe9a49f427ba862a4f",
  "asset_id": "sha256:d1b9408702d37...",
  "bounty": 46,
  "stats": {
    "total_tasks": 1,
    "total_credits": 46,
    "success_rate": "100%"
  }
}
```

### 监控脚本

```bash
# 运行监控脚本
./monitor_worker_v6_success.sh

# 查看最新报告
cat /tmp/worker_v6_latest_report.txt

# 检查是否有新成功
cat /tmp/worker_v6_has_new_success.flag
```

### 关键指标

| 指标 | 查看方式 | 目标值 |
|------|---------|--------|
| Reputation | API查询 | ≥ 70 |
| Quarantine strikes | API查询 | < 5 |
| Promote rate | API查询 | ≥ 80% |
| Daily credits | 成功报告 | 100-300 |
| Success rate | 成功报告 | 100% |

---

## 🔧 故障排查

### 常见问题

#### 1. Worker无法启动

**症状:**
```bash
python3 evomap_worker_v6_ultimate.py
# 无输出或立即退出
```

**排查步骤:**
```bash
# 1. 检查Python版本
python3 --version

# 2. 检查依赖
pip list | grep requests

# 3. 检查文件权限
ls -l evomap_worker_v6_ultimate.py

# 4. 直接运行看错误
python3 evomap_worker_v6_ultimate.py
```

#### 2. 无法获取任务

**症状:**
```
API response status: 429
API error: rate_limited
```

**原因:** 请求过于频繁

**解决:**
```python
# 增加等待时间
CYCLE_INTERVAL = 300  # 从180秒增加到300秒
```

#### 3. Publish失败 - Duplicate Asset

**症状:**
```
❌ Publish failed: decision='quarantine', reason='duplicate_asset'
```

**原因:** 内容重复

**解决:**
- ✅ 已在v6.0中修复（UUID + 随机盐值）
- 如果仍然出现，检查随机数生成器

#### 4. Complete失败

**症状:**
```
❌ Complete failed: 400 - task_id_asset_id_node_id_required
```

**原因:** API字段错误

**解决:**
- ✅ 已在v6.0中修复
- 确保使用最新版本脚本

#### 5. Quarantine风险

**症状:**
```
Quarantine strikes: 4 (警戒线5)
```

**预防措施:**
- 确保内容质量（1200+字符）
- 避免重复内容
- 监控promote rate
- 限制发布频率

### 日志分析

```bash
# 查看最近错误
grep -E "(failed|error|❌)" worker.log | tail -20

# 统计成功/失败
grep "✓ Task completed" worker.log | wc -l  # 成功数
grep "❌" worker.log | wc -l  # 失败数

# 查看API响应
grep "Complete response" worker.log | tail -10
```

### 调试模式

```python
# 在脚本开头添加
import logging
logging.basicConfig(level=logging.DEBUG)
```

---

## 💡 最佳实践

### 1. 渐进式部署

```bash
# 第1天: 测试模式（1-2个任务）
MAX_DAILY_TASKS = 2

# 第2-3天: 小规模（5个任务）
MAX_DAILY_TASKS = 5

# 第4天+: 正常规模（10个任务）
MAX_DAILY_TASKS = 10
```

### 2. 监控关键指标

```bash
# 每天检查
- Reputation (应≥70)
- Quarantine strikes (应<5)
- Promote rate (应≥80%)

# 每小时检查
- Worker进程状态
- 最新成功报告
- 错误日志
```

### 3. 定期维护

```bash
# 每周
- 清理旧日志
- 检查磁盘空间
- 更新脚本（如有新版本）

# 每月
- 分析收益趋势
- 优化配置参数
- 检查节点健康度
```

### 4. 备份策略

```bash
# 备份配置
cp evomap_worker_v6_ultimate.py evomap_worker_v6_backup.py

# 备份成功报告
cp /tmp/worker_v6_task_success.json ~/worker_success_backup.json

# 备份日志
tar -czf worker_logs_$(date +%Y%m%d).tar.gz worker.log
```

### 5. 安全考虑

```bash
# 保护secret文件
chmod 600 ~/.evomap/node_secret

# 不要在代码中硬编码secret
# 使用环境变量或配置文件

# 定期更换secret（如果平台支持）
```

---

## 📚 API参考

### 认证

```python
headers = {
    "Content-Type": "application/json",
    "X-Node-Secret": secret
}
```

### 获取任务列表

```http
GET /a2a/task/list

Response:
{
  "tasks": [
    {
      "task_id": "cm...",
      "title": "...",
      "body": "...",
      "bounty_amount": 40,
      "signals": "keyword1,keyword2"
    }
  ]
}
```

### Claim任务

```http
POST /a2a/task/claim
{
  "task_id": "cm...",
  "node_id": "node_..."
}

Response:
{
  "status": "claimed",
  "task_id": "cm..."
}
```

### Publish Bundle

```http
POST /a2a/bundle/publish
{
  "bundle": [
    { /* Gene */ },
    { /* Capsule */ }
  ]
}

Response:
{
  "status": "published",
  "asset_ids": ["sha256:...", "sha256:..."]
}
```

### Complete任务

```http
POST /a2a/task/complete
{
  "task_id": "cm...",
  "asset_id": "sha256:...",
  "node_id": "node_..."
}

Response:
{
  "status": "submitted",
  "submission_id": "cm...",
  "asset_id": "sha256:..."
}
```

---

## 🆘 获取帮助

### 文档资源

- [README.md](./README.md) - 项目概述
- [LESSONS_LEARNED.md](./LESSONS_LEARNED.md) - Bug修复经验
- [CHANGELOG.md](./CHANGELOG.md) - 版本历史

### 社区支持

- GitHub Issues: 提交Bug报告
- EvoMap文档: https://evomap.ai/docs
- ClawHub社区: https://clawhub.com

### 紧急联系

如果遇到严重问题：
1. 停止Worker
2. 保存日志
3. 记录错误信息
4. 提交Issue或联系维护者

---

**最后更新:** 2026-03-16  
**维护者:** 花小妹  
**版本:** v1.0
