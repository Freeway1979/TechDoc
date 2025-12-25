[Redis](https://github.com/redis/ioredis?tab=readme-ov-file) 作为高性能的内存数据库，在实际应用中需遵循最佳实践以确保其稳定性、性能和安全性。以下从数据结构、内存管理、持久化、高可用、性能优化等方面总结核心实践：

## [->Redis API](https://redis.github.io/ioredis/classes/Redis.html)

### **一、数据结构选择：用对结构，事半功倍**
Redis 提供字符串（String）、哈希（Hash）、列表（List）、集合（Set）、有序集合（Sorted Set）等数据结构，**选择合适的结构可减少内存占用并提升操作效率**。

| 场景                  | 推荐结构         | 避免做法                          |
|-----------------------|------------------|-----------------------------------|
| 简单键值对（如 token） | String           | 用 Hash 存储单个键值（浪费空间）  |
| 存储对象（如用户信息） | Hash             | 用多个 String 存储对象字段        |
| 队列/栈（如消息队列） | List（LPUSH/RPOP）| 用 Set 模拟（无序，无阻塞操作）   |
| 去重场景（如 UV 统计） | Set              | 用 List 手动去重（效率极低）      |
| 排序/排名（如积分榜） | Sorted Set       | 用 List 存储后在应用层排序        |
| 位运算（如签到统计）  | String（BITOP）  | 用 Set 存储签到日期（内存占用高） |

**示例**：存储用户信息时，用 Hash 比多个 String 更高效：  
```bash
# 推荐：一个 Hash 存储用户所有字段
HSET user:1001 name "Alice" age 25 email "alice@example.com"

# 不推荐：多个 String 存储
SET user:1001:name "Alice"
SET user:1001:age 25
```


### **二、内存管理：控制占用，避免溢出**
Redis 是内存数据库，内存不足会导致服务崩溃或数据丢失，需合理规划内存使用。

1. **设置最大内存限制**  
   通过 `maxmemory` 配置限制 Redis 可使用的最大内存（单位：字节），避免耗尽系统内存：  
   ```conf
   maxmemory 4gb  # 限制最大内存为 4GB
   ```

2. **选择合适的内存淘汰策略**  
   当内存达到 `maxmemory` 时，Redis 会根据 `maxmemory-policy` 淘汰旧数据，需根据业务场景选择：  
   - `volatile-lru`：淘汰**设置了过期时间**的键中，最近最少使用的（适合缓存场景）。  
   - `allkeys-lru`：淘汰**所有键**中最近最少使用的（适合全内存数据库场景）。  
   - `volatile-ttl`：淘汰**设置了过期时间**的键中，剩余 TTL 最短的（适合限时数据）。  
   - 避免使用 `noeviction`（默认，不淘汰数据，会拒绝新写入，导致服务异常）。  

   配置示例：  
   ```conf
   maxmemory-policy volatile-lru  # 缓存场景首选
   ```

3. **避免“大 Key”**  
   大 Key（如包含百万级元素的 Hash/Set）会导致：  
   - 内存碎片率升高，浪费空间；  
   - 操作（如删除、序列化）耗时过长，阻塞 Redis 主线程；  
   - 网络传输延迟增大。  

   **检测大 Key**：  
   ```bash
   redis-cli --bigkeys  # 扫描并列出大 Key（按元素数或字节数）
   ```

   **解决方法**：  
   - 拆分大 Key：如将一个大 Hash 拆分为多个小 Hash（`user:1001:info` → `user:1001:base`、`user:1001:ext`）。  
   - 限制单 Key 大小：业务层控制，如列表最多存储 1000 条数据。

4. **及时清理过期数据**  
   Redis 采用“惰性删除+定期删除”清理过期键，可能存在过期键未及时删除的情况，可：  
   - 主动删除不再需要的键（`DEL key`）；  
   - 对批量过期的键，设置随机过期时间（如 `expire key $base_time + rand(0, 300)`），避免集中删除导致卡顿。


### **三、持久化策略：平衡性能与数据安全**
Redis 提供 RDB 和 AOF 两种持久化方式，需根据业务对“数据安全性”和“性能”的需求选择。

| 特性         | RDB（快照）                          | AOF（ Append-Only File）             |
|--------------|--------------------------------------|--------------------------------------|
| 原理         | 定期生成内存快照（二进制文件）        | 记录所有写命令到日志文件              |
| 优点         | 恢复速度快，文件体积小                | 数据安全性高（最多丢失 1 秒数据）      |
| 缺点         | 可能丢失最近 N 分钟数据（依赖快照间隔）| 文件体积大，恢复速度慢                |
| 适用场景     | 备份、全量恢复，对数据丢失不敏感场景  | 核心业务，对数据安全性要求高的场景    |

**最佳实践**：  
- **核心业务**：开启 AOF + RDB 结合模式（AOF 保证数据安全，RDB 用于快速恢复）。  
- **非核心业务**：仅开启 RDB（降低性能损耗）。  

**AOF 关键配置**：  
```conf
appendonly yes  # 开启 AOF
appendfsync everysec  # 每秒同步一次（平衡安全性和性能，最多丢失 1 秒数据）
auto-aof-rewrite-percentage 100  # AOF 文件增长 100% 时触发重写（压缩文件）
auto-aof-rewrite-min-size 64mb  # 最小重写大小
```

**RDB 关键配置**：  
```conf
save 3600 1    # 3600 秒内有 1 次写操作，触发快照
save 300 100   # 300 秒内有 100 次写操作，触发快照
```


### **四、高可用架构：避免单点故障**
单机 Redis 存在单点故障风险，需通过主从复制、哨兵（Sentinel）或集群（Cluster）保证高可用。

1. **主从复制：读写分离**  
   - 主库（Master）：处理写操作，同步数据到从库。  
   - 从库（Slave）：处理读操作，减轻主库压力。  

   配置示例（从库 `redis.conf`）：  
   ```conf
   replicaof master_ip master_port  # 指向主库 IP 和端口
   replica-read-only yes  # 从库只读（默认）
   ```

   **注意**：主从复制是异步的，主库故障可能丢失少量数据。

2. **哨兵（Sentinel）：自动故障转移**  
   哨兵监控主从集群，当主库故障时自动将从库升级为主库，恢复服务。  
   最少部署 3 个哨兵节点（避免脑裂），配置示例：  
   ```conf
   sentinel monitor mymaster master_ip master_port 2  # 监控名为 mymaster 的主库，2 个哨兵同意则判定主库故障
   sentinel down-after-milliseconds mymaster 30000  # 30 秒未响应则标记为主观下线
   ```

3. **Redis Cluster：数据分片与高可用**  
   当数据量超过单节点内存上限时，使用集群实现**数据分片**（将数据分散到 16384 个槽位，由多个节点分担），同时支持副本机制（每个主节点可配置从节点）。  
   - 最少部署 3 主 3 从（保证高可用）。  
   - 避免“数据倾斜”（某节点槽位数据过多），需合理分配槽位。  


### **五、性能优化：提升响应速度**
1. **批量操作：减少网络往返**  
   用 Pipeline 批量执行命令（减少 TCP 往返次数），尤其适合大量写操作：  
   ```python
   # Python 示例（redis-py）
   pipe = r.pipeline()
   for i in range(1000):
       pipe.set(f"key:{i}", i)
   pipe.execute()  # 批量执行，仅 1 次网络往返
   ```

2. **避免阻塞命令**  
    Redis 是单线程，耗时命令（如 `KEYS *`、`HGETALL bighash`）会阻塞主线程，导致服务卡顿。  
   - 用 `SCAN` 替代 `KEYS`（渐进式扫描，不阻塞）：  
     ```bash
     SCAN 0 MATCH user:* COUNT 100  # 每次扫描 100 个键，返回游标用于下次扫描
     ```
   - 用 `HSCAN`/`SSCAN` 等分批获取大 Key 数据。

3. **合理使用连接池**  
   频繁创建/关闭连接会消耗资源，通过连接池复用连接：  
   ```java
   // Java 示例（Jedis）
   JedisPool pool = new JedisPool(new JedisPoolConfig(), "localhost", 6379);
   try (Jedis jedis = pool.getResource()) {
       jedis.set("key", "value");
   }
   ```

4. **控制并发连接数**  
   通过 `maxclients` 限制最大连接数（默认 10000），避免连接过多耗尽资源：  
   ```conf
   maxclients 5000  # 根据服务器性能调整
   ```


### **六、缓存策略：解决常见问题**
1. **缓存穿透**（查询不存在的 Key，穿透到数据库）  
   - 解决方案：缓存空值（`SET key "" EX 60`）；用布隆过滤器预过滤不存在的 Key。  

2. **缓存击穿**（热点 Key 过期瞬间，大量请求穿透到数据库）  
   - 解决方案：热点 Key 永不过期；加互斥锁（如 Redis `SETNX`），只允许一个请求重建缓存。  

3. **缓存雪崩**（大量 Key 同时过期，数据库压力骤增）  
   - 解决方案：过期时间加随机值（`expire key 3600 + rand(0, 300)`）；多级缓存（本地缓存 + Redis）。  


### **七、安全措施：防止未授权访问**
1. **设置密码**：通过 `requirepass` 配置访问密码，避免未授权操作：  
   ```conf
   requirepass strong_password  # 使用复杂密码（字母+数字+符号）
   ```

2. **限制网络访问**：通过 `bind` 限制仅允许信任的 IP 连接：  
   ```conf
   bind 127.0.0.1 192.168.1.100  # 只允许本地和 192.168.1.100 访问
   ```

3. **禁用危险命令**：重命名或禁用 `FLUSHALL`、`FLUSHDB`、`KEYS` 等危险命令：  
   ```conf
   rename-command FLUSHALL ""  # 禁用 FLUSHALL
   rename-command KEYS "HIDDEN_KEYS"  # 重命名为复杂名称
   ```


### **八、监控与维护**
1. **实时监控**：通过 `INFO` 命令查看 Redis 状态（内存、CPU、命中率等）：  
   ```bash
   redis-cli info memory  # 查看内存信息
   redis-cli info stats   # 查看统计信息（如 keyspace_hits/misses 计算命中率）
   ```
   命中率 = `keyspace_hits / (keyspace_hits + keyspace_misses)`，理想值 > 90%。

2. **定期备份**：结合 RDB 做定时备份（如每天凌晨），并测试恢复流程。

3. **版本升级**：及时升级到稳定版本，修复已知漏洞（如 Redis 4.0+ 支持更完善的内存淘汰策略）。


### **总结**
Redis 最佳实践的核心是：**选对数据结构、控制内存占用、平衡持久化策略、构建高可用架构、优化性能并防范安全风险**。需结合业务场景（如缓存、计数、队列等）灵活调整配置，避免“一刀切”。