Using ClickHouse with Node.js efficiently requires leveraging ClickHouse's strengths (columnar storage, high throughput for analytics) while following best practices for performance, data modeling, and error handling. Below is a comprehensive guide to best practices, with code examples using the official Node.js client.


### **1. Choose the Right Client**  
Use the **official ClickHouse Node.js client** (`@clickhouse/client`) – it’s maintained by ClickHouse, supports modern features (streaming, compression, TLS), and is optimized for performance.  

Install it:  
```bash
npm install @clickhouse/client
# For TypeScript (optional)
npm install -D @types/clickhouse__client
```


### **2. Connection Configuration**  
Configure the client for reliability and performance. Key settings:  

- **Connection Pooling**: Reuse connections to avoid overhead.  
- **Compression**: Enable `gzip` for large data transfers.  
- **Timeouts**: Set reasonable timeouts for queries/inserts.  
- **Retry Logic**: Handle transient errors (e.g., network blips).  

```javascript
const { createClient } = require('@clickhouse/client');

const clickhouse = createClient({
  host: 'http://localhost:8123', // ClickHouse HTTP endpoint
  username: 'default',
  password: '', // Default for local instances; set in production
  database: 'default',
  compression: {
    request: 'gzip', // Compress requests
    response: 'gzip', // Decompress responses
  },
  keep_alive: true, // Reuse TCP connections
  query_timeout: 60_000, // 60s timeout for queries
  insert_timeout: 300_000, // 5min timeout for large inserts
});
```


### **3. Data Modeling: Optimize Table Design**  
ClickHouse’s performance depends heavily on table structure. Follow these rules:  

#### **a. Use the Right Engine**  
- **MergeTree Family**: Default for most analytical use cases (supports partitioning, sorting, TTL).  
- **ReplacingMergeTree**: For deduplication (e.g., upserts).  
- **Distributed**: For cluster setups (sharding).  

#### **b. Partitioning**  
Partition large tables by time (e.g., daily) to limit scan ranges. Use `Date` or `DateTime` columns.  

#### **c. Sorting Key**  
Define a `ORDER BY` key to optimize query performance (e.g., frequently filtered/grouped columns).  

#### **Example Table Creation**  
```javascript
// Create a table for user behavior logs (optimized for time-based analytics)
async function createUserBehaviorTable() {
  const query = `
    CREATE TABLE IF NOT EXISTS user_behavior (
      event_date Date, -- Partition key (daily)
      event_time DateTime, -- Sort key component
      user_id UInt64, -- Sort key component
      action String, -- e.g., 'click', 'purchase'
      product_id UInt64,
      city String
    ) ENGINE = MergeTree()
    PARTITION BY event_date -- Partition by day
    ORDER BY (event_time, user_id) -- Sort by time + user for fast filters
    TTL event_date + INTERVAL 90 DAY DELETE; -- Auto-delete data older than 90 days
  `;

  await clickhouse.command({ query });
  console.log('Table created/verified');
}
```


### **4. Batch Inserts: Maximize Throughput**  
ClickHouse is optimized for **bulk inserts** (not single-row writes). Accumulate data and insert in batches to minimize round-trips.  

#### **Best Practices for Inserts**  
- Use `JSONEachRow` format (native for Node.js objects).  
- Batch size: 1,000–10,000 rows per insert (adjust based on row size).  
- Avoid `INSERT` in a loop for single rows.  

```javascript
// Example: Batch insert user behavior events
async function batchInsert(events) {
  // events = [{ event_date: '2024-01-01', event_time: '2024-01-01 12:00:00', ... }, ...]
  const query = `
    INSERT INTO user_behavior
    (event_date, event_time, user_id, action, product_id, city)
    FORMAT JSONEachRow
  `;

  // Use .insert() with the batch data
  await clickhouse.insert({
    query,
    values: events, // Array of objects matching the table schema
    format: 'JSONEachRow',
  });
}

// Usage: Accumulate events and insert in batches
const events = [];
for (let i = 0; i < 5000; i++) { // 5,000 rows per batch
  events.push({
    event_date: '2024-01-01',
    event_time: '2024-01-01 12:00:00',
    user_id: 1000 + i,
    action: i % 2 === 0 ? 'click' : 'purchase',
    product_id: 5000 + i,
    city: 'New York',
  });
}
await batchInsert(events);
```


### **5. Query Optimization**  
ClickHouse excels at analytics, but poorly written queries can negate its performance.  

#### **a. Filter Early with Partitions**  
Leverage partition keys (e.g., `event_date`) to limit scanned data:  
```javascript
// Good: Filters by partition key first
const query = `
  SELECT action, COUNT(*) AS count
  FROM user_behavior
  WHERE event_date BETWEEN '2024-01-01' AND '2024-01-31' -- Scans only Jan partitions
    AND city = 'New York'
  GROUP BY action
`;
```

#### **b. Avoid `SELECT *`**  
Only fetch needed columns (columnar storage reads only requested columns):  
```javascript
// Bad: Reads all columns (wastes I/O)
SELECT * FROM user_behavior WHERE event_date = '2024-01-01'

// Good: Reads only required columns
SELECT user_id, action FROM user_behavior WHERE event_date = '2024-01-01'
```

#### **c. Stream Large Results**  
For large datasets (100k+ rows), stream results to avoid memory overload:  
```javascript
async function streamLargeQuery() {
  const query = `
    SELECT user_id, event_time
    FROM user_behavior
    WHERE event_date BETWEEN '2024-01-01' AND '2024-01-31'
  `;

  const stream = await clickhouse.query({
    query,
    format: 'JSONEachRow', // Stream row-by-row
  }).stream();

  // Process rows as they arrive
  for await (const row of stream) {
    console.log(`User ${row.user_id} at ${row.event_time}`);
    // Add to batch or process incrementally
  }
}
```

#### **d. Use Materialized Views for Aggregates**  
Precompute frequent aggregates (e.g., daily counts) with materialized views to speed up queries:  
```javascript
async function createMaterializedView() {
  const query = `
    CREATE MATERIALIZED VIEW IF NOT EXISTS daily_action_counts
    ENGINE = SummingMergeTree()
    PARTITION BY event_date
    ORDER BY (event_date, action)
    AS SELECT
      event_date,
      action,
      COUNT(*) AS total
    FROM user_behavior
    GROUP BY event_date, action
  `;
  await clickhouse.command({ query });
}
```


### **6. Handle Errors and Retries**  
ClickHouse may fail due to network issues, temporary overload, or invalid queries. Implement retries for transient errors.  

Use `p-retry` for retry logic:  
```bash
npm install p-retry
```

```javascript
const pRetry = require('p-retry');

async function safeQuery(query) {
  return pRetry(
    async () => {
      try {
        return await clickhouse.query({ query }).rows();
      } catch (error) {
        // Retry on transient errors (e.g., 503, network timeout)
        if (error.code === 'ECONNRESET' || error.status === 503) {
          throw error; // Trigger retry
        }
        // Don't retry on permanent errors (e.g., invalid SQL)
        throw new pRetry.AbortError(error.message);
      }
    },
    {
      retries: 3, // Max 3 retries
      minTimeout: 1000, // 1s between retries
    }
  );
}

// Usage
const results = await safeQuery('SELECT COUNT(*) FROM user_behavior');
```


### **7. Type Safety**  
ClickHouse has strict data types (e.g., `UInt64`, `Date`). Ensure Node.js types match:  
- **Dates**: Use `YYYY-MM-DD` (for `Date`) or `YYYY-MM-DD HH:MM:SS` (for `DateTime`).  
- **Numbers**: Avoid floating points for integers (use `UInt64` for IDs).  
- **Strings**: Escape special characters (client auto-escapes in `JSONEachRow`).  


### **8. Monitor and Profile Queries**  
- **Log Slow Queries**: Use ClickHouse’s `system.query_log` to track slow queries:  
  ```sql
  SELECT query, elapsed FROM system.query_log WHERE elapsed > 5 ORDER BY elapsed DESC LIMIT 10
  ```  
- **Client-Side Timing**: Log query durations to identify bottlenecks:  
  ```javascript
  async function timedQuery(query) {
    const start = Date.now();
    const result = await clickhouse.query({ query }).rows();
    const duration = Date.now() - start;
    if (duration > 1000) { // Log queries slower than 1s
      console.warn(`Slow query (${duration}ms): ${query}`);
    }
    return result;
  }
  ```  


### **9. Cleanup Resources**  
Close the client when the app exits to free connections:  
```javascript
process.on('SIGINT', async () => {
  await clickhouse.close();
  process.exit(0);
});
```


### **Summary of Best Practices**  
1. Use the official `@clickhouse/client` for reliability.  
2. Optimize table design with `MergeTree`, partitioning, and sorting keys.  
3. Batch inserts (1k–10k rows) with `JSONEachRow` format.  
4. Stream large query results to avoid memory issues.  
5. Filter early with partition keys and avoid `SELECT *`.  
6. Implement retries for transient errors.  
7. Monitor slow queries and ensure type safety.  

By following these practices, you’ll maximize ClickHouse’s performance in Node.js applications, especially for analytics and large-scale data processing.