#!/bin/bash
# EvoMap Status Check Script
# Author: 花小妹

set -e

# Configuration
NODE_ID="YOUR_NODE_ID"
SECRET_FILE="$HOME/.evomap/node_secret"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if secret exists
if [ ! -f "$SECRET_FILE" ]; then
    echo -e "${RED}Error: Secret file not found at $SECRET_FILE${NC}"
    exit 1
fi

SECRET=$(cat "$SECRET_FILE")

echo "======================================"
echo "EvoMap Status Check"
echo "======================================"
echo ""

# Node Status
echo -e "${YELLOW}Node Status:${NC}"
curl -s "https://evomap.ai/a2a/nodes/$NODE_ID" | jq '{
  total_published,
  total_promoted,
  reputation,
  online,
  survival_status,
  last_seen_at
}'
echo ""

# Worker Status
echo -e "${YELLOW}Worker Status:${NC}"
curl -s "https://evomap.ai/a2a/work/available?node_id=$NODE_ID" | jq '{
  worker_enabled: .worker_enabled // false,
  pending_assignments: (.assignments | length) // 0
}'
echo ""

# Recent Assets
echo -e "${YELLOW}Recent Assets:${NC}"
curl -s "https://evomap.ai/a2a/assets?node_id=$NODE_ID&limit=5" | jq '.assets[] | {
  asset_id: .asset_id[0:20],
  type,
  status,
  created_at
}'
echo ""

# Platform Stats
echo -e "${YELLOW}Platform Stats:${NC}"
curl -s "https://evomap.ai/a2a/stats" | jq '{
  total_assets,
  promoted_assets,
  promotion_rate,
  total_nodes
}'
echo ""

# Promotion Rate
PROMOTED=$(curl -s "https://evomap.ai/a2a/nodes/$NODE_ID" | jq -r '.total_promoted')
TOTAL=$(curl -s "https://evomap.ai/a2a/nodes/$NODE_ID" | jq -r '.total_published')

if [ "$TOTAL" != "null" ] && [ "$TOTAL" != "0" ]; then
    RATE=$(echo "scale=2; $PROMOTED * 100 / $TOTAL" | bc)
    echo -e "${GREEN}Your Promotion Rate: ${RATE}%${NC}"
else
    echo -e "${YELLOW}No assets published yet${NC}"
fi

echo ""
echo "======================================"
