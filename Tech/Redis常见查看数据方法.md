在 Redis 命令行中查看数据的方法取决于数据的类型（如字符串、哈希、列表等）。以下是针对不同数据类型的查看命令及操作示例：


ssh ubuntu@3.138.168.55
./mspcli redis exec -d qici-dev2

### **一、连接 Redis 命令行**
首先通过 `redis-cli` 连接到 Redis 服务器（默认本地连接）：
```bash
# 本地默认连接（127.0.0.1:6379）
redis-cli

# 连接远程服务器或指定端口/密码
redis-cli -h 服务器IP -p 端口 -a 密码
```

连接成功后，提示符会显示为 `127.0.0.1:6379>`。


### **二、通用命令（适用于所有类型）**
#### 1. 查看所有键（`KEYS`）
```bash
# 查看所有键（生产环境慎用，数据量大时会阻塞服务器）
KEYS *

# 模糊匹配（如查看所有以 "user:" 开头的键）
KEYS user:*
```

#### 2. 查看键的类型（`TYPE`）
```bash
TYPE 键名  # 返回键的类型（string/hash/list/set/zset 等）
```
示例：
```bash
TYPE user:1001  # 若返回 hash，说明该键是哈希类型
```

#### 3. 检查键是否存在（`EXISTS`）
```bash
EXISTS 键名  # 1 表示存在，0 表示不存在
```


### **三、按数据类型查看数据**
#### 1. 字符串（String）
- 命令：`GET 键名`
```bash
# 设置一个字符串键
SET name "Alice"

# 查看值
GET name  # 返回 "Alice"
```


#### 2. 哈希（Hash）
- 查看所有字段和值：`HGETALL 键名`
- 查看单个字段值：`HGET 键名 字段名`
```bash
# 设置哈希键
HSET user:1001 name "Bob" age 30 email "bob@example.com"

# 查看所有字段和值
HGETALL user:1001
# 返回：
# 1) "name"
# 2) "Bob"
# 3) "age"
# 4) "30"
# 5) "email"
# 6) "bob@example.com"

# 查看单个字段（如 age）
HGET user:1001 age  # 返回 "30"
```


#### 3. 列表（List）
- 查看指定范围元素：`LRANGE 键名 起始索引 结束索引`（`0` 表示第一个，`-1` 表示最后一个）
```bash
# 设置列表键
LPUSH tasks "task1" "task2"
RPUSH tasks "task3"

# 查看所有元素（0 到 -1）
LRANGE tasks 0 -1  # 返回 1) "task2" 2) "task1" 3) "task3"

# 查看前 2 个元素
LRANGE tasks 0 1  # 返回 1) "task2" 2) "task1"
```


#### 4. 集合（Set）
- 查看所有元素：`SMEMBERS 键名`
```bash
# 设置集合键
SADD tags "js" "node" "redis"

# 查看所有元素
SMEMBERS tags  # 返回 1) "js" 2) "node" 3) "redis"（顺序不固定）
```


#### 5. 有序集合（Sorted Set）
- 按分数升序查看：`ZRANGE 键名 起始索引 结束索引 [WITHSCORES]`
- 按分数降序查看：`ZREVRANGE 键名 起始索引 结束索引 [WITHSCORES]`
```bash
# 设置有序集合键（分数+成员）
ZADD scores 90 "Alice" 85 "Bob" 95 "Charlie"

# 升序查看所有元素（带分数）
ZRANGE scores 0 -1 WITHSCORES
# 返回：
# 1) "Bob"
# 2) "85"
# 3) "Alice"
# 4) "90"
# 5) "Charlie"
# 6) "95"

# 降序查看前 2 名（带分数）
ZREVRANGE scores 0 1 WITHSCORES
# 返回：
# 1) "Charlie"
# 2) "95"
# 3) "Alice"
# 4) "90"
```


### **四、高级查看技巧**
#### 1. 分页查看大量键（`SCAN`）
替代 `KEYS *`（避免阻塞），渐进式遍历键：
```bash
# 从游标 0 开始，每次扫描 10 个键（匹配 "user:*"）
SCAN 0 MATCH user:* COUNT 10
# 返回：1) "12"（下一个游标） 2) 1) "user:1001" 2) "user:1002"

# 继续扫描（使用上一次返回的游标）
SCAN 12 MATCH user:* COUNT 10
# 直到返回游标为 0 表示扫描完成
```

#### 2. 查看键的过期时间（`TTL`/`PTTL`）
```bash
TTL 键名  # 剩余过期时间（秒，-1 表示永不过期，-2 表示已过期）
PTTL 键名 # 剩余过期时间（毫秒）
```

#### 3. 实时监控数据变化（`MONITOR`）
实时打印服务器接收到的所有命令（调试用）：
```bash
MONITOR
# 此时执行的所有 Redis 命令都会被打印出来
```
按 `Ctrl+C` 退出监控。


### **总结**
查看 Redis 数据的核心是：
1. 先用 `KEYS` 或 `SCAN` 找到目标键；
2. 用 `TYPE` 确认键的类型；
3. 用对应类型的查看命令（如 `GET` 对应字符串，`HGETALL` 对应哈希）获取数据。

根据数据类型选择合适的命令，可高效查看和调试 Redis 中的数据。