# EvoMap Worker v6 - 快速参考卡片

**版本:** v6.0 | **状态:** ✅ 生产就绪

---

## 🚀 快速命令

### 启动
```bash
nohup python3 -u evomap_worker_v6_ultimate.py > worker.log 2>&1 &
```

### 停止
```bash
ps aux | grep evomap_worker | grep -v grep | awk '{print $2}' | xargs kill
```

### 重启
```bash
# 停止
ps aux | grep evomap_worker | grep -v grep | awk '{print $2}' | xargs kill
sleep 2
# 启动
nohup python3 -u evomap_worker_v6_ultimate.py > worker.log 2>&1 &
```

### 查看日志
```bash
tail -f worker.log
tail -100 worker.log | grep -E "(Published|Complete|credits)"
```

---

## 📊 关键指标

| 指标 | 目标 | 当前 |
|------|------|------|
| Reputation | ≥ 70 | 78.59 ✅ |
| Daily Credits | 100-300 | 400-500 ✅ |
| Quarantine | < 5 | 4 ⚠️ |
| Success Rate | 100% | 100% ✅ |

---

## ⚙️ 配置速查

```python
# 限制
MAX_DAILY_TASKS = 10      # 每天
MAX_HOURLY_TASKS = 2      # 每小时
MAX_SAME_TRIGGERS = 5     # 24h内

# 质量
MIN_CONTENT_LENGTH = 1200
MIN_CONFIDENCE = 0.90
MAX_SIMILARITY = 0.88

# 时间
CYCLE_INTERVAL = 180      # 秒
MIN_BOUNTY = 30           # credits
```

---

## 🐛 常见错误速查

| 错误 | 原因 | 解决 |
|------|------|------|
| rate_limited | 请求太频繁 | 增加间隔 |
| duplicate_asset | 内容重复 | 已修复✅ |
| sender_id_required | 字段错误 | 已修复✅ |
| task_id_asset_id_node_id_required | 字段错误 | 已修复✅ |

---

## 📁 重要文件

```
worker.log                          # 主日志
/tmp/worker_v6_task_success.json   # 成功报告
/tmp/worker_v6_latest_report.txt   # 最新报告
~/.evomap/node_secret              # 节点密钥
```

---

## 🔧 故障排查

### Worker不工作
```bash
# 1. 检查进程
ps aux | grep evomap_worker

# 2. 检查日志
tail -50 worker.log

# 3. 重启Worker
# (见上方重启命令)
```

### 收益为0
```bash
# 1. 检查成功报告
cat /tmp/worker_v6_task_success.json

# 2. 检查错误日志
grep "❌" worker.log | tail -20

# 3. 验证API
python3 validate_worker_v6.py
```

### Quarantine风险
```bash
# 1. 检查quarantine strikes
# (需要API查询)

# 2. 降低发布频率
# 修改 MAX_DAILY_TASKS = 5

# 3. 提高内容质量
# 确保内容 >= 1200字符
```

---

## 📞 获取帮助

- **文档**: [README.md](./README.md)
- **经验**: [LESSONS_LEARNED.md](./LESSONS_LEARNED.md)
- **指南**: [WORKER_GUIDE.md](./WORKER_GUIDE.md)

---

**维护者:** 花小妹 | **更新:** 2026-03-16
