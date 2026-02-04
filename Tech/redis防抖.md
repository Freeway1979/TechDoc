
Redis 的 **原子操作** 和极快的读写速度使其非常适合作为临时注册表来处理高频的防抖和节流需求。

-----

## 最佳实践：Redis 注册表防抖 (Node.js/ioredis)

该模式利用 Redis 的 **`SET` 命令结合 `NX` (Not eXist) 和 `GET`** 属性，来实现原子性的\*\*“比较并设置”\*\*逻辑，防止竞态条件。

### 架构流程

1.  **生产者 (Producer)**：将带有唯一标识符（如 `userId`）和 **当前时间戳** 的消息推送到 SQS。
2.  **SQS 延迟 (Delay)**：消息在 SQS 中等待一段预设的防抖时间（例如 5 秒）。
3.  **Worker Lambda (防抖检查)**：
      * 接收 SQS 消息后，计算出该消息的 **Key**。
      * 使用 Redis **原子性地比较**该消息的时间戳与 Redis 中存储的时间戳。
      * 如果该消息是 **最新** 的，则更新 Redis 记录并执行业务逻辑；否则，丢弃该消息。

### 1\. Redis Key 结构

使用一个固定的前缀和事件的唯一标识符来构造 Key，并用 **Sorted Set (ZSET)** 或 **String** 来存储时间戳。这里我们使用 **String** 类型结合 `SETEX` (Set with Expiration) 来实现。

  * **Key 格式:** `debounce:<userId>`
  * **Value:** 生产者发送时的最新时间戳（例如 `1732041234567` 毫秒）。
  * **TTL (Time To Live):** 设置一个过期时间，自动清理旧记录。

### 2\. Node.js Worker Lambda 代码

以下代码使用 **`ioredis`** 客户端，并利用 Redis 的事务和 Lua 脚本来保证\*\*比较和设置（Check-and-Set）\*\*的原子性。

```javascript
// Worker Lambda - index.js

const Redis = require('ioredis');

// 配置
const REDIS_HOST = process.env.REDIS_HOST || 'your-redis-endpoint.cache.amazonaws.com';
const REDIS_TTL_SECONDS = 60 * 60; // Redis 记录保留 1 小时
const QUEUE_PREFIX = 'debounce:';

// 初始化 Redis 客户端 (应放在处理函数外部以利用 Cold Start 优化)
const rclient = new Redis({
    host: REDIS_HOST,
    port: 6379,
    // 确保 socketTimeout 足够长，以支持任何潜在的 BRPOP 阻塞操作 (虽然这里没有用到)
    socketTimeout: 30000 
});

/**
 * 模拟核心业务逻辑
 */
async function processJob(jobData) {
    console.log(`[CORE LOGIC] Successfully processing user ID: ${jobData.userId}`);
    // 在此处添加您的数据库写入、API 调用等核心业务逻辑
}

// Lua 脚本用于原子性地比较并设置时间戳
// 脚本逻辑：
// 1. 获取当前 Key 的时间戳。
// 2. 如果 Key 不存在，或者新时间戳大于旧时间戳，则设置新值并返回 1 (处理)。
// 3. 否则，返回 0 (丢弃)。
const DEBOUNCE_LUA_SCRIPT = `
    local current_time = redis.call('GET', KEYS[1])
    local new_time = ARGV[1]
    local ttl = ARGV[2]

    if current_time == false or tonumber(new_time) > tonumber(current_time) then
        redis.call('SET', KEYS[1], new_time, 'EX', ttl)
        return 1 -- 成功更新，处理消息
    else
        return 0 -- 旧消息，丢弃
    end
`;

/**
 * SQS 事件处理器
 */
export const handler = async (event) => {
    // 注册 Lua 脚本
    rclient.defineCommand('atomicDebounce', {
        numberOfKeys: 1,
        lua: DEBOUNCE_LUA_SCRIPT
    });
    
    const successfulMessages = [];
    const failedMessages = [];

    for (const record of event.Records) {
        try {
            const messageBody = JSON.parse(record.body);
            // 假设消息来自 SNS，需要二次解析。如果直接来自 SQS，则不需要 messageBody.Message
            const payload = JSON.parse(messageBody.Message || record.body); 
            
            const userId = payload.userId;
            const eventTimestamp = payload.timestamp; // 生产者发送时的最新时间戳

            if (!userId || !eventTimestamp) {
                console.warn(`Skipping message due to missing data: ${record.messageId}`);
                continue;
            }

            const debounceKey = `${QUEUE_PREFIX}${userId}`;
            
            // 1. 调用原子防抖脚本
            // KEYS[1]: debounceKey
            // ARGV[1]: eventTimestamp
            // ARGV[2]: REDIS_TTL_SECONDS
            const result = await rclient.atomicDebounce(
                debounceKey, 
                eventTimestamp, 
                REDIS_TTL_SECONDS
            );

            if (result === 1) {
                // 2. 脚本返回 1：说明 Redis 已更新，这是最新消息，执行核心业务
                console.log(`[PASS] Processing NEWEST event for User: ${userId}`);
                await processJob(payload);
            } else {
                // 3. 脚本返回 0：说明 Redis 中存在一个更新的时间戳，这是旧消息，丢弃
                console.log(`[DEBOUNCED] Old message dropped for User: ${userId}.`);
            }
            
            successfulMessages.push({ itemIdentifier: record.messageId });

        } catch (error) {
            console.error(`Failed to process message ${record.messageId}:`, error);
            // 标记为失败，让 SQS 重试
            failedMessages.push({ itemIdentifier: record.messageId });
        }
    }
    
    // 返回 SQS 批处理报告
    return {
        batchItemFailures: failedMessages,
    };
};
```

### 关键优势和最佳实践

1.  **原子性（Atomicity）:** 这是最大的优势。通过使用 **Lua 脚本**，Redis 在单个操作中执行了 **GET、比较、SET 和 EXPIRE** 四个步骤。这消除了多个 Lambda 实例同时读写 Redis 造成的竞态条件。
2.  **极速性能:** Redis 可以在微秒级别完成去重检查，远快于 DynamoDB 的写入操作，极大地降低了 Worker 的执行延迟。
3.  **自动清理 (TTL):** 通过 `SET ... EX` 或 `SETEX` 命令设置的 **TTL**，确保了防抖记录在一段时间后自动从 Redis 中删除，无需额外的清理逻辑。
4.  **专用于防抖:** Redis 非常适合处理这种**高频、临时性**的状态检查，完美地契合了防抖的需求。