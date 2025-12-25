#!/bin/bash

# 定义循环次数
MAX_ITERATIONS=100

# 定义基础 URL 和头部信息
URL='http://localhost:8834/v1/encipher/simple?command=cmd&item=policy:create&sync_to_msp=1'
HEADER='Content-Type: application/json'

# 定义基础 IP 地址的最后一位（从 2 开始）
LAST_OCTET=2

# Group/User ID 作为脚本的第一个参数传入
if [ -z "$1" ]; then
    echo "Usage: $0 <Group/User ID>"
    exit 1
fi
TARGET_GROUP_ID=$1

echo "--- 开始发送 ${MAX_ITERATIONS} 次循环请求 ---"

# 循环 100 次
for i in $(seq 1 $MAX_ITERATIONS); do
    
    # 构造完整的 IP 地址 (4.2.2.X)
    CURRENT_IP="4.2.2.${LAST_OCTET}"
    
    # 构造 JSON 数据，注意要用双引号包围单引号，以避免Bash变量扩展问题
    # 或者像下面这样，使用 HEREDOC 结构来定义 JSON，更清晰
    JSON_DATA=$(cat <<EOF
{
  "action": "allow",
  "type": "ip",
  "target": "${CURRENT_IP}",
  "dnsmasq_only": false,
  "tag": ["tag:${TARGET_GROUP_ID}"],
}
EOF
)
    
    echo "Iteration $i: Sending request for IP: $CURRENT_IP"
    
    # 执行 curl 请求
    # -s: 静默模式，不显示进度或错误
    # -w "%{http_code}\n": 打印 HTTP 状态码
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -H "$HEADER" \
        -d "$JSON_DATA" \
        "$URL")

    echo "  -> HTTP Status Code: $RESPONSE_CODE"
    
    # 递增 IP 地址的最后一位
    LAST_OCTET=$((LAST_OCTET + 1))
    
    # 检查 IP 地址是否溢出 (例如，如果需要超过 254)
    if [ "$LAST_OCTET" -gt 254 ]; then
        echo "警告: IP 地址最后一位达到 254，停止递增。"
        # 可以选择重置 LAST_OCTET=2 或者退出脚本
    fi
    
    # 暂停 1.5 秒
    sleep 1.5
done

echo "--- 循环请求发送完毕 ---"