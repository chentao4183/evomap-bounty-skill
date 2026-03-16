#!/bin/bash
# Worker v6 自动报告监控
# 每次heartbeat时检查是否有新的任务完成

SUCCESS_FILE="/tmp/worker_v6_task_success.json"
LAST_SEEN_FILE="/tmp/worker_v6_last_success_count.txt"
NOTIFY_FILE="/tmp/worker_v6_new_success_notify.txt"

# 如果没有成功文件，退出
if [ ! -f "$SUCCESS_FILE" ]; then
    exit 0
fi

# 统计当前成功任务数
CURRENT_COUNT=$(jq '. | length' "$SUCCESS_FILE" 2>/dev/null || echo "0")

# 读取上次看到的数量
if [ -f "$LAST_SEEN_FILE" ]; then
    LAST_COUNT=$(cat "$LAST_SEEN_FILE")
else
    LAST_COUNT="0"
fi

# 如果有新任务
if [ "$CURRENT_COUNT" -gt "$LAST_COUNT" ]; then
    NEW_TASKS=$((CURRENT_COUNT - LAST_COUNT))
    
    # 获取最新的任务报告
    LATEST=$(jq '.[-1]' "$SUCCESS_FILE")
    
    TIMESTAMP=$(echo "$LATEST" | jq -r '.timestamp')
    TASK_ID=$(echo "$LATEST" | jq -r '.task_id')
    BOUNTY=$(echo "$LATEST" | jq -r '.bounty')
    STATS=$(echo "$LATEST" | jq -r '.stats')
    
    # 生成通知内容
    cat > "$NOTIFY_FILE" << EOF
✅ **任务完成报告**
时间: $TIMESTAMP

**任务详情:**
- 任务ID: ${TASK_ID:0:20}...
- Bounty: $BOUNTY credits

**当前统计:**
$STATS

---
本次新增: $NEW_TASKS 个任务
累计完成: $CURRENT_COUNT 个任务
EOF
    
    # 更新计数
    echo "$CURRENT_COUNT" > "$LAST_SEEN_FILE"
    
    # 输出标记（供OpenClaw检测）
    echo "HAS_NEW_SUCCESS" > /tmp/worker_v6_has_new_success.flag
fi
