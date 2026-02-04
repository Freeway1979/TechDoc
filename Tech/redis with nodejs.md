Beyond the basic `SET` and `GET` operations, Redis offers powerful data structures and performance features that are essential for building robust, high-performance Node.js applications.

Here is a deeper dive into using Redis with Node.js, focusing on advanced features and best practices with the `ioredis` library.

### 1\. Redis Advanced Data Structures

Redis is not just a simple key-value store. It provides five main data types, each with its own unique use cases.

#### a) Hashes (Objects)

Hashes are perfect for storing objects. They allow you to group related fields and values under a single key.

```javascript
// Example: Storing user data
const user = { name: "Alice", email: "alice@example.com", age: 30 };
await redis.hmset("user:1", user);

// Get a single field
const userName = await redis.hget("user:1", "name"); // "Alice"

// Get all fields
const allUserData = await redis.hgetall("user:1");
// { name: 'Alice', email: 'alice@example.com', age: '30' }
// Note: All values are returned as strings
```

#### b) Lists (Queues)

Lists are ordered collections of strings. They are commonly used for implementing queues, stacks, or message passing.

```javascript
// Example: A job queue
await redis.lpush("jobQueue", "job:101", "job:102");
// The list now contains ["job:102", "job:101"]

const newJob = await redis.rpop("jobQueue"); // "job:101"
const anotherJob = await redis.rpop("jobQueue"); // "job:102"
```

#### c) Sets (Unique Items)

Sets are collections of unique, unordered strings. They are great for tracking unique items or performing set operations like unions and intersections.

```javascript
// Example: Tracking unique visitors
await redis.sadd("uniqueVisitors", "userA", "userB", "userC", "userA"); // 'userA' is ignored
const visitorCount = await redis.scard("uniqueVisitors"); // 3

// Get all members of the set
const allVisitors = await redis.smembers("uniqueVisitors");
// ['userA', 'userB', 'userC']
```

#### d) Sorted Sets (Leaderboards)

Sorted Sets are like Sets, but each member is associated with a numeric score. They are ideal for building leaderboards, ranking systems, or time-series data.

```javascript
// Example: Building a leaderboard
await redis.zadd("leaderboard", 100, "playerA", 150, "playerB", 80, "playerC");

// Get the top 2 players
const topPlayers = await redis.zrevrange("leaderboard", 0, 1, "WITHSCORES");
// [ 'playerB', '150', 'playerA', '100' ]
```

-----

### 2\. Performance Optimizations

Node.js is a single-threaded, non-blocking environment. The biggest performance bottleneck with Redis is network latency from multiple round trips.

#### a) Pipelining

Pipelining allows you to send multiple commands to Redis in a single request and receive all responses in a single reply. This dramatically reduces network overhead.

```javascript
// Without pipelining (multiple network round trips)
await redis.set("key1", "value1");
await redis.set("key2", "value2");
await redis.set("key3", "value3");

// With pipelining (one network round trip)
const pipeline = redis.pipeline();
pipeline.set("key1", "value1");
pipeline.set("key2", "value2");
pipeline.set("key3", "value3");
const responses = await pipeline.exec();
// `responses` is an array of [error, result] for each command
```

#### b) Transactions (`MULTI`/`EXEC`)

Redis transactions guarantee that a group of commands is executed atomically—either all commands are run successfully or none are. This prevents race conditions.

```javascript
// Example: Atomically decrement a counter and add a message to a list
const multi = redis.multi();
multi.decr("items_available");
multi.lpush("recent_purchases", "item:123");
const results = await multi.exec();
// The two commands are guaranteed to run together without interruption from other clients
```

**Note:** Redis transactions are not the same as SQL database transactions; if a command in a transaction fails, subsequent commands will still execute.

-----

### 3\. Connection Management Best Practices

  * **Singleton Pattern:** In a production application, you should create a single Redis client instance and reuse it throughout your application. This is because creating a new connection for every command is slow and resource-intensive. `ioredis` handles connection pooling internally, so one instance is enough.
  * **Automatic Reconnection:** `ioredis` handles automatic reconnection by default, so you don't need to manually re-establish a connection if it drops.
  * **Properly Close Connections:** When your application is shutting down, always call `redis.quit()` to gracefully close the connection.

### A Complete, Runnable Example

```javascript
const Redis = require("ioredis");
const redis = new Redis();

async function main() {
    try {
        // --- 1. Pipelining Example ---
        console.log("--- Pipelining commands ---");
        const pipeline = redis.pipeline();
        pipeline.hset("user:101", "name", "Charlie", "email", "charlie@test.com");
        pipeline.incr("totalUsers");
        pipeline.sadd("activeSessions", "user:101");
        await pipeline.exec();
        console.log("Pipelined commands executed successfully.");
        
        // --- 2. Using Advanced Data Structures ---
        console.log("\n--- Using Redis Hashes and Sets ---");
        const user = await redis.hgetall("user:101");
        console.log("User 101 data:", user);
        
        const activeCount = await redis.scard("activeSessions");
        console.log(`Active session count: ${activeCount}`);
        
        // --- 3. Transaction Example ---
        console.log("\n--- Running a transaction (MULTI/EXEC) ---");
        const transaction = redis.multi();
        transaction.set("counter", 1);
        transaction.incr("counter");
        transaction.incr("counter");
        
        const results = await transaction.exec();
        console.log("Transaction results:", results.map(res => res[1]));
        
    } catch (err) {
        console.error("An error occurred:", err);
    } finally {
        redis.quit();
    }
}

// Event listeners for robust connection management
redis.on("error", (err) => {
    console.error("Redis connection error:", err);
});

redis.on("connect", () => {
    console.log("Successfully connected to Redis.");
});

main();
```

