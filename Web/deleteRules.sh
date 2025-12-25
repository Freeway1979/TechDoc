#!/bin/bash

# 定义循环的起始和结束 Policy ID
START_ID=531
END_ID=631

# 定义基础 URL 和头部信息
URL='http://localhost:8834/v1/encipher/simple?command=cmd&item=policy:delete&sync_to_msp=1'
HEADER='Content-Type: application/json'

echo "--- 开始发送策略删除请求（ID: $START_ID 到 $END_ID） ---"

# 循环从 START_ID 到 END_ID
for policy_id in $(seq $START_ID $END_ID); do
    
    # 构造 JSON 数据，将当前的 policy_id 插入到 "policyID" 字段
    JSON_DATA=$(cat <<EOF
{
  "policyID": "$policy_id"
}
EOF
)
    
    echo "Deleting Policy ID: $policy_id"
    
    # 执行 curl 请求
    # -s: 静默模式，不显示进度或错误
    # -w "%{http_code}": 打印 HTTP 状态码
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -H "$HEADER" \
        -d "$JSON_DATA" \
        "$URL")

    echo "  -> HTTP Status Code: $RESPONSE_CODE"
    
    # 暂停 2 秒
    sleep 2
done

echo "--- 所有策略删除请求发送完毕 ---"