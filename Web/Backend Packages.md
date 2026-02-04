# Package Dependencies Overview

This document provides an introduction to all packages used in the Fireguard project, along with basic usage examples.

## Production Dependencies

### @clickhouse/client (^0.0.16)
**Purpose**: Official ClickHouse database client for Node.js.

**Basic Usage**:
```javascript
const { createClient } = require('@clickhouse/client');

const client = createClient({
  host: 'http://localhost:8123',
  username: 'default',
  password: '',
});

const result = await client.query({
  query: 'SELECT * FROM table',
  format: 'JSONEachRow',
});
```

---

### @slack/webhook (^6.0.0)
**Purpose**: Send messages to Slack using incoming webhooks.

**Basic Usage**:
```javascript
const { IncomingWebhook } = require('@slack/webhook');

const webhook = new IncomingWebhook(process.env.SLACK_WEBHOOK_URL);
await webhook.send({
  text: 'Hello from Fireguard!',
});
```

---

### @socket.io/redis-emitter (^4.1.0)
**Purpose**: Emit Socket.IO events across multiple servers using Redis pub/sub.

**Basic Usage**:
```javascript
const { Emitter } = require('@socket.io/redis-emitter');
const { createClient } = require('redis');

const redisClient = createClient();
const io = new Emitter(redisClient);

io.emit('event', { data: 'message' });
```

---

### @vendia/serverless-express (^4.5.2)
**Purpose**: Run Express.js applications in AWS Lambda.

**Basic Usage**:
```javascript
const serverlessExpress = require('@vendia/serverless-express');
const app = require('./app');

exports.handler = serverlessExpress({ app });
```

---

### ajv (^8.17.1)
**Purpose**: JSON Schema validator.

**Basic Usage**:
```javascript
const Ajv = require('ajv');
const ajv = new Ajv();

const schema = {
  type: 'object',
  properties: {
    name: { type: 'string' },
    age: { type: 'number' },
  },
  required: ['name'],
};

const validate = ajv.compile(schema);
const valid = validate({ name: 'John', age: 30 });
```

---

### ajv-formats (^3.0.1)
**Purpose**: Format validation for Ajv (email, date, URI, etc.).

**Basic Usage**:
```javascript
const Ajv = require('ajv');
const addFormats = require('ajv-formats');

const ajv = new Ajv();
addFormats(ajv);

const validate = ajv.compile({
  type: 'object',
  properties: {
    email: { type: 'string', format: 'email' },
  },
});
```

---

### aws-embedded-metrics (4.2.0)
**Purpose**: Generate CloudWatch embedded metric format logs.

**Basic Usage**:
```javascript
const { createMetricsLogger, Unit } = require('aws-embedded-metrics');

const metrics = createMetricsLogger();
metrics.putMetric('ProcessingLatency', 100, Unit.Milliseconds);
metrics.putProperty('RequestId', 'abc-123');
await metrics.flush();
```

---

### aws-sdk (^2.1045.0)
**Purpose**: AWS SDK for JavaScript (v2).

**Basic Usage**:
```javascript
const AWS = require('aws-sdk');

const s3 = new AWS.S3({ region: 'us-west-1' });
const result = await s3.getObject({
  Bucket: 'my-bucket',
  Key: 'my-key',
}).promise();
```

---

### bluebird (^3.5.2)
**Purpose**: Promise library with additional utilities.

**Basic Usage**:
```javascript
const Promise = require('bluebird');

Promise.map([1, 2, 3], async (n) => n * 2);
Promise.delay(1000); // Wait 1 second
```

---

### chai (^4.3.10)
**Purpose**: BDD/TDD assertion library for testing.

**Basic Usage**:
```javascript
const { expect } = require('chai');

expect(2 + 2).to.equal(4);
expect([1, 2, 3]).to.include(2);
```

---

### child-process-promise (^2.2.1)
**Purpose**: Promise-based wrapper for child_process.

**Basic Usage**:
```javascript
const { exec } = require('child-process-promise');

const result = await exec('ls -la');
console.log(result.stdout);
```

---

### compression (^1.7.4)
**Purpose**: Express middleware for response compression.

**Basic Usage**:
```javascript
const compression = require('compression');
const express = require('express');

const app = express();
app.use(compression());
```

---

### cookie-parser (~1.4.3)
**Purpose**: Parse Cookie header and populate req.cookies.

**Basic Usage**:
```javascript
const cookieParser = require('cookie-parser');
const express = require('express');

const app = express();
app.use(cookieParser());

app.get('/', (req, res) => {
  console.log(req.cookies);
});
```

---

### copy-webpack-plugin (^10.0.0)
**Purpose**: Copy files and directories with webpack.

**Basic Usage**:
```javascript
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  plugins: [
    new CopyWebpackPlugin({
      patterns: [{ from: 'static', to: 'dist' }],
    }),
  ],
};
```

---

### cron (^1.8.2)
**Purpose**: Cron job scheduler for Node.js.

**Basic Usage**:
```javascript
const CronJob = require('cron').CronJob;

const job = new CronJob('0 0 * * *', () => {
  console.log('Running daily at midnight');
});
job.start();
```

---

### cross-var (^1.1.0)
**Purpose**: Cross-platform environment variable substitution in npm scripts.

**Basic Usage**:
```json
{
  "scripts": {
    "deploy": "cross-var aws deploy --region $npm_package_config_region"
  }
}
```

---

### date-fns (^2.29.3)
**Purpose**: Modern JavaScript date utility library.

**Basic Usage**:
```javascript
const { format, addDays, differenceInDays } = require('date-fns');

format(new Date(), 'yyyy-MM-dd');
addDays(new Date(), 7);
differenceInDays(new Date('2024-01-01'), new Date());
```

---

### debug (~2.6.9)
**Purpose**: Small debugging utility.

**Basic Usage**:
```javascript
const debug = require('debug')('app:server');

debug('Server starting on port 3000');
// Set DEBUG=app:server to see output
```

---

### decompress (^4.2.1)
**Purpose**: Extract archives (zip, tar, etc.).

**Basic Usage**:
```javascript
const decompress = require('decompress');

await decompress('archive.zip', 'dist');
```

---

### express (~4.16.0)
**Purpose**: Fast, unopinionated web framework for Node.js.

**Basic Usage**:
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({ message: 'Hello World' });
});

app.listen(3000);
```

---

### express-jwt (^5.3.1)
**Purpose**: JWT authentication middleware for Express.

**Basic Usage**:
```javascript
const expressJwt = require('express-jwt');

app.use(expressJwt({
  secret: 'secret',
  algorithms: ['HS256'],
}));
```

---

### express-unless (^0.5.0)
**Purpose**: Conditionally skip middleware.

**Basic Usage**:
```javascript
const unless = require('express-unless');

const middleware = expressJwt({ secret: 'secret' });
middleware.unless = unless;

app.use(middleware.unless({ path: ['/login', '/public'] }));
```

---

### faker (^5.5.3)
**Purpose**: Generate fake data for testing.

**Basic Usage**:
```javascript
const faker = require('faker');

faker.name.findName();
faker.internet.email();
faker.address.city();
```

---

### filenamify (4.3.0)
**Purpose**: Convert a string to a valid filename.

**Basic Usage**:
```javascript
const filenamify = require('filenamify');

filenamify('foo:bar'); // 'foo!bar'
```

---

### filesize (^10.1.0)
**Purpose**: Convert bytes to human-readable file sizes.

**Basic Usage**:
```javascript
const filesize = require('filesize');

filesize(1024); // '1 KB'
filesize(1048576); // '1 MB'
```

---

### format-message (^5.2.1)
**Purpose**: Internationalization message formatting.

**Basic Usage**:
```javascript
const formatMessage = require('format-message');

formatMessage('Hello {name}', { name: 'World' });
```

---

### geoip-lite (^1.3.8)
**Purpose**: GeoIP lookup by IP address.

**Basic Usage**:
```javascript
const geoip = require('geoip-lite');

const geo = geoip.lookup('8.8.8.8');
console.log(geo.country, geo.city);
```

---

### ip (^1.1.8)
**Purpose**: IP address utilities.

**Basic Usage**:
```javascript
const ip = require('ip');

ip.isV4Format('192.168.1.1');
ip.cidrSubnet('192.168.1.0/24');
```

---

### is-valid-domain (^0.1.6)
**Purpose**: Validate domain names.

**Basic Usage**:
```javascript
const isValidDomain = require('is-valid-domain');

isValidDomain('example.com'); // true
isValidDomain('invalid..domain'); // false
```

---

### json2csv (^5.0.7)
**Purpose**: Convert JSON to CSV.

**Basic Usage**:
```javascript
const { parse } = require('json2csv');

const fields = ['field1', 'field2'];
const opts = { fields };
const csv = parse([{ field1: 'a', field2: 'b' }], opts);
```

---

### jsonwebtoken (^8.3.0)
**Purpose**: JSON Web Token implementation.

**Basic Usage**:
```javascript
const jwt = require('jsonwebtoken');

const token = jwt.sign({ userId: 123 }, 'secret', { expiresIn: '1h' });
const decoded = jwt.verify(token, 'secret');
```

---

### jszip (^3.9.1)
**Purpose**: Create, read, and edit .zip files.

**Basic Usage**:
```javascript
const JSZip = require('jszip');

const zip = new JSZip();
zip.file('hello.txt', 'Hello World');
const content = await zip.generateAsync({ type: 'nodebuffer' });
```

---

### jwk-to-pem (^2.0.5)
**Purpose**: Convert JWK to PEM format.

**Basic Usage**:
```javascript
const jwkToPem = require('jwk-to-pem');

const pem = jwkToPem({
  kty: 'RSA',
  n: '...',
  e: 'AQAB',
});
```

---

### moment (^2.22.2)
**Purpose**: Parse, validate, manipulate, and display dates.

**Basic Usage**:
```javascript
const moment = require('moment');

moment().format('YYYY-MM-DD');
moment().add(1, 'days');
moment('2024-01-01').isBefore('2024-01-02');
```

---

### moment-timezone (^0.5.34)
**Purpose**: Timezone support for Moment.js.

**Basic Usage**:
```javascript
const moment = require('moment-timezone');

moment.tz('2024-01-01', 'America/New_York');
moment().tz('Asia/Tokyo').format();
```

---

### morgan (~1.9.0)
**Purpose**: HTTP request logger middleware for Express.

**Basic Usage**:
```javascript
const morgan = require('morgan');

app.use(morgan('combined'));
app.use(morgan('dev'));
```

---

### mustache-express (^1.2.8)
**Purpose**: Mustache template engine for Express.

**Basic Usage**:
```javascript
const mustacheExpress = require('mustache-express');

app.engine('mustache', mustacheExpress());
app.set('view engine', 'mustache');
app.set('views', './views');
```

---

### parse-domain (^3.0.3)
**Purpose**: Parse domain names into parts.

**Basic Usage**:
```javascript
const parseDomain = require('parse-domain');

parseDomain('subdomain.example.co.uk');
// { subdomain: 'subdomain', domain: 'example', tld: 'co.uk' }
```

---

### prom-client (^12.0.0)
**Purpose**: Prometheus client for Node.js.

**Basic Usage**:
```javascript
const client = require('prom-client');

const counter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
});

counter.inc();
```

---

### punycode (^2.3.0)
**Purpose**: Punycode encoding/decoding (for internationalized domain names).

**Basic Usage**:
```javascript
const punycode = require('punycode');

punycode.encode('mañana');
punycode.decode('maana-pta');
```

---

### qr-image (^3.2.0)
**Purpose**: Generate QR code images.

**Basic Usage**:
```javascript
const qr = require('qr-image');

const qr_png = qr.image('Hello World', { type: 'png' });
qr_png.pipe(require('fs').createWriteStream('qr.png'));
```

---

### qrcode (^1.5.0)
**Purpose**: QR code generator.

**Basic Usage**:
```javascript
const QRCode = require('qrcode');

const dataUrl = await QRCode.toDataURL('Hello World');
await QRCode.toFile('qr.png', 'Hello World');
```

---

### rate-limiter-flexible (~7.1.1)
**Purpose**: Rate limiting library.

**Basic Usage**:
```javascript
const { RateLimiterMemory } = require('rate-limiter-flexible');

const rateLimiter = new RateLimiterMemory({
  points: 5, // 5 requests
  duration: 60, // per 60 seconds
});

try {
  await rateLimiter.consume(req.ip);
} catch (rejRes) {
  res.status(429).send('Too Many Requests');
}
```

---

### redis (^2.8.0)
**Purpose**: Redis client for Node.js.

**Basic Usage**:
```javascript
const redis = require('redis');
const client = redis.createClient();

client.set('key', 'value');
const value = await client.get('key');
```

---

### request-promise (^4.2.2)
**Purpose**: Simplified HTTP request client with Promise support.

**Basic Usage**:
```javascript
const rp = require('request-promise');

const response = await rp({
  uri: 'https://api.example.com/data',
  json: true,
});
```

---

### sqlstring (^2.3.3)
**Purpose**: SQL escape and format utilities.

**Basic Usage**:
```javascript
const SqlString = require('sqlstring');

SqlString.escape('user\'s data');
SqlString.format('SELECT * FROM users WHERE id = ?', [123]);
```

---

### subnet-overlap (^1.0.0)
**Purpose**: Check if two subnets overlap.

**Basic Usage**:
```javascript
const subnetOverlap = require('subnet-overlap');

subnetOverlap('192.168.1.0/24', '192.168.1.128/25'); // true
```

---

### supports-color (^9.2.1)
**Purpose**: Detect whether a terminal supports color.

**Basic Usage**:
```javascript
const supportsColor = require('supports-color');

if (supportsColor.stdout) {
  console.log('\u001b[36mcyan\u001b[39m');
}
```

---

### swagger-express-mw (^0.7.0)
**Purpose**: Swagger middleware for Express.

**Basic Usage**:
```javascript
const SwaggerExpress = require('swagger-express-mw');

SwaggerExpress.create({ appRoot: __dirname }, (err, swaggerExpress) => {
  swaggerExpress.register(app);
});
```

---

### swagger-ui-dist (^3.20.1)
**Purpose**: Swagger UI distribution files.

**Basic Usage**:
```javascript
const swaggerUiAssetPath = require('swagger-ui-dist').absolutePath();
app.use('/swagger-ui', express.static(swaggerUiAssetPath));
```

---

### swagger-ui-express (^4.0.1)
**Purpose**: Serve Swagger UI from Express.

**Basic Usage**:
```javascript
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('./swagger.json');

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
```

---

### tweetnacl (^1.0.3)
**Purpose**: High-speed cryptographic library.

**Basic Usage**:
```javascript
const nacl = require('tweetnacl');

const keypair = nacl.box.keyPair();
const nonce = nacl.randomBytes(24);
const encrypted = nacl.box(message, nonce, recipientPublicKey, senderSecretKey);
```

---

### uuid (^9.0.1)
**Purpose**: Generate RFC-compliant UUIDs.

**Basic Usage**:
```javascript
const { v4: uuidv4 } = require('uuid');

const id = uuidv4(); // '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d'
```

---

### uws (^200.0.0)
**Purpose**: WebSocket library (deprecated, use ws instead).

**Basic Usage**:
```javascript
const uws = require('uws');

const server = uws.Server({ port: 3000 });
server.on('connection', (ws) => {
  ws.send('Hello');
});
```

---

### vertx (^0.0.1-security)
**Purpose**: Security placeholder package (prevents typosquatting).

**Note**: This is a security package that doesn't provide functionality.

---

### webpack-cli (^4.9.1)
**Purpose**: Command-line interface for webpack.

**Basic Usage**:
```bash
npx webpack-cli --config webpack.config.js
```

---

### yamljs (^0.3.0)
**Purpose**: YAML parser and dumper.

**Basic Usage**:
```javascript
const YAML = require('yamljs');

const obj = YAML.load('config.yaml');
const yamlString = YAML.stringify({ key: 'value' });
```

---

## Development Dependencies

### should (^7.1.0)
**Purpose**: BDD assertion library.

**Basic Usage**:
```javascript
const should = require('should');

(2 + 2).should.equal(4);
[1, 2, 3].should.include(2);
```

---

### supertest (^1.0.0)
**Purpose**: HTTP assertions for testing.

**Basic Usage**:
```javascript
const request = require('supertest');
const app = require('./app');

request(app)
  .get('/api/users')
  .expect(200)
  .end((err, res) => {
    if (err) throw err;
  });
```

---

### webpack (^5.64.4)
**Purpose**: Module bundler for JavaScript.

**Basic Usage**:
```javascript
// webpack.config.js
module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: __dirname + '/dist',
  },
};
```

---

### eslint (8.57.1)
**Purpose**: JavaScript linter.

**Basic Usage**:
```bash
npx eslint src/
npx eslint --fix src/
```

---

### nyc (15.1.0)
**Purpose**: Code coverage tool for JavaScript.

**Basic Usage**:
```bash
nyc mocha test/
nyc report --reporter=html
```

---

### mocha (10.7.3)
**Purpose**: JavaScript test framework.

**Basic Usage**:
```javascript
// test.js
const assert = require('assert');

describe('Array', () => {
  describe('#indexOf()', () => {
    it('should return -1 when value is not present', () => {
      assert.equal([1, 2, 3].indexOf(4), -1);
    });
  });
});
```

---

## Summary

This project uses a comprehensive set of packages for:
- **Web Framework**: Express.js with serverless support
- **Database**: ClickHouse, Redis
- **Authentication**: JWT, JWK
- **Testing**: Mocha, Chai, Supertest
- **Build Tools**: Webpack
- **Monitoring**: Prometheus, CloudWatch
- **Utilities**: Date handling, validation, compression, file operations
- **AWS Integration**: AWS SDK, Lambda deployment tools

