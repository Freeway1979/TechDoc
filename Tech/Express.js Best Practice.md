Express.js is a minimalist and flexible Node.js web framework, but following best practices ensures maintainability, security, and performance. Here’s a curated guide to key best practices:


### **1. Project Structure: Keep It Organized**  
A clean structure simplifies scaling and collaboration. Avoid cluttering `app.js` with all logic. A typical structure:  
```
project/
├── src/
│   ├── config/          # Configuration (DB, env vars, etc.)
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Custom middleware (auth, validation)
│   ├── models/          # Database models
│   ├── routes/          # Route definitions
│   ├── services/        # Business logic
│   ├── utils/           # Helpers/utility functions
│   ├── app.js           # Express app setup
│   └── server.js        # Entry point (starts server)
├── .env                 # Environment variables (gitignored)
├── .env.example         # Example env vars (committed)
├── package.json
└── .gitignore
```


### **2. Use Environment Variables**  
Never hardcode sensitive data (API keys, DB URLs). Use `dotenv` to manage environment variables:  

1. Install:  
   ```bash
   npm install dotenv
   ```  

2. Create `.env`:  
   ```env
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/mydb
   JWT_SECRET=your_secure_secret
   NODE_ENV=development
   ```  

3. Load in `src/config/env.js` (or entry file):  
   ```javascript
   require('dotenv').config();

   module.exports = {
     port: process.env.PORT || 3000,
     mongoUri: process.env.MONGODB_URI,
     jwtSecret: process.env.JWT_SECRET,
     nodeEnv: process.env.NODE_ENV || 'development'
   };
   ```  

4. Add `.env` to `.gitignore` to avoid exposing secrets.  


### **3. Simplify Routing**  
Separate routes from business logic. Define routes in dedicated files and attach them to the app.  

**Example: `src/routes/user.routes.js`**  
```javascript
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');

// Define routes
router.get('/', authenticate, userController.getAllUsers);
router.get('/:id', authenticate, userController.getUserById);
router.post('/', userController.createUser);

module.exports = router;
```  

**Attach to app in `app.js`:**  
```javascript
const express = require('express');
const app = express();
const userRoutes = require('./routes/user.routes');

// Mount routes
app.use('/api/users', userRoutes);
```  


### **4. Use Middleware Wisely**  
- **Order matters**: Place global middleware (e.g., `express.json()`) before routes.  
- **Error-handling middleware** should be last (with 4 parameters: `err, req, res, next`).  

**Essential Middleware:**  
- `express.json()`: Parse JSON request bodies (replace deprecated `body-parser`).  
- `morgan`: Log HTTP requests (development).  
- `helmet`: Secure HTTP headers.  
- `cors`: Handle cross-origin requests.  

**Example `app.js` setup:**  
```javascript
const express = require('express');
const morgan = require('morgan');
const helmet = require('helmet');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');
const config = require('./config/env');

const app = express();

// Global middleware
if (config.nodeEnv === 'development') {
  app.use(morgan('dev')); // Log requests in dev
}
app.use(helmet()); // Secure headers
app.use(cors()); // Enable CORS
app.use(express.json()); // Parse JSON bodies

// Routes
app.use('/api/users', require('./routes/user.routes'));

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: `Route not found: ${req.originalUrl}` });
});

// Error-handling middleware (last!)
app.use(errorHandler);

module.exports = app;
```  


### **5. Centralized Error Handling**  
Create a global error-handling middleware to standardize error responses.  

**`src/middleware/errorHandler.js`**  
```javascript
const config = require('../config/env');

const errorHandler = (err, req, res, next) => {
  // Default error status and message
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  // In production, hide sensitive error details
  const errorResponse = {
    status: 'error',
    message,
    ...(config.nodeEnv === 'development' && { stack: err.stack }) // Show stack trace in dev
  };

  res.status(statusCode).json(errorResponse);
};

module.exports = { errorHandler };
```  

**Throw custom errors in controllers/services:**  
```javascript
// Example in a controller
const getUserById = async (req, res, next) => {
  try {
    const user = await userService.findById(req.params.id);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error; // Will be caught by errorHandler
    }
    res.json(user);
  } catch (err) {
    next(err); // Pass to error handler
  }
};
```  


### **6. Validate Requests**  
Always validate user input to prevent invalid data and security risks. Use libraries like `joi` or `express-validator`.  

**Example with `express-validator`:**  
1. Install:  
   ```bash
   npm install express-validator
   ```  

2. Create a validation middleware (`src/middleware/validation.js`):  
   ```javascript
   const { body, validationResult } = require('express-validator');

   // Validate user creation
   const validateUserCreation = [
     body('email').isEmail().withMessage('Invalid email'),
     body('password').isLength({ min: 6 }).withMessage('Password too short'),
     body('name').notEmpty().withMessage('Name is required'),
     
     // Check for validation errors
     (req, res, next) => {
       const errors = validationResult(req);
       if (!errors.isEmpty()) {
         return res.status(400).json({ errors: errors.array() });
       }
       next();
     }
   ];

   module.exports = { validateUserCreation };
   ```  

3. Use in routes:  
   ```javascript
   const { validateUserCreation } = require('../middleware/validation');
   router.post('/', validateUserCreation, userController.createUser);
   ```  


### **7. Secure Your App**  
- **Use `helmet`**: Sets HTTP headers to prevent common vulnerabilities (e.g., XSS, clickjacking).  
- **Sanitize inputs**: Prevent NoSQL injection or XSS with `express-mongo-sanitize` or `xss-clean`.  
- **Rate limiting**: Use `express-rate-limit` to prevent brute-force attacks.  
- **CORS configuration**: Restrict origins in production:  
  ```javascript
  app.use(cors({
    origin: config.nodeEnv === 'production' ? 'https://yourfrontend.com' : '*'
  }));
  ```  
- **Avoid `eval()` and `new Function()`**: They execute arbitrary code and pose security risks.  


### **8. Optimize Performance**  
- **Avoid synchronous operations**: They block the event loop. Use async/await for I/O (DB calls, API requests).  
- **Cache responses**: Use `apicache` or Redis to cache frequent requests (e.g., public data).  
- **Compress responses**: Use `compression` middleware to gzip responses:  
  ```bash
  npm install compression
  ```  
  ```javascript
  const compression = require('compression');
  app.use(compression()); // Place before routes
  ```  


### **9. Database Best Practices**  
- **Use connection pools**: Reuse DB connections (e.g., MongoDB, PostgreSQL) to avoid overhead.  
- **Separate DB logic**: Keep database operations in `models/` or `services/`, not in controllers.  
- **Sanitize queries**: Use ORMs (Sequelize, Mongoose) to prevent SQL/NoSQL injection.  


### **10. Logging and Monitoring**  
- **Request logging**: Use `morgan` for HTTP logs in development.  
- **Application logs**: Use `winston` or `pino` for structured logging (errors, info):  
  ```javascript
  const winston = require('winston');
  const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    transports: [new winston.transports.File({ filename: 'error.log', level: 'error' })]
  });
  ```  
- **Monitor performance**: Use tools like New Relic, Datadog, or OpenTelemetry.  


### **11. Testing**  
Write tests for routes, middleware, and services using `jest` or `mocha`. Example with `supertest` for API testing:  

```bash
npm install jest supertest --save-dev
```  

**Test example (`tests/user.routes.test.js`):**  
```javascript
const request = require('supertest');
const app = require('../src/app');

describe('User Routes', () => {
  it('should create a user', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: 'Test', email: 'test@example.com', password: 'password123' });
    expect(res.statusCode).toEqual(201);
  });
});
```  


### **12. Deployment**  
- **Use a process manager**: `pm2` to keep the app running and restart on crashes:  
  ```bash
  npm install pm2 -g
  pm2 start src/server.js --name "my-app"
  ```  
- **Set `NODE_ENV=production`**: Disables Express debug mode and enables optimizations.  
- **Use a reverse proxy**: Nginx or Apache to handle SSL termination, load balancing, and static files.  


By following these practices, you’ll build Express apps that are secure, maintainable, and performant. For more details, refer to the [official Express documentation](https://expressjs.com/en/guide/best-practice.html).