const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { collectDefaultMetrics, Counter, Histogram, register } = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3001;
const conn = require('./conn');

app.use(express.json());
app.use(cors());

// --- Metrics setup ---
collectDefaultMetrics(); // collects CPU, memory, event loop, etc.

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5],
});

const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'code'],
});

const httpErrorCount = new Counter({
  name: 'http_error_count',
  help: 'Number of HTTP errors',
  labelNames: ['method', 'route', 'code'],
});

// Middleware to measure request latency and error count
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const route = req.route ? req.route.path : req.path;
    httpRequestsTotal.labels(req.method, route, res.statusCode).inc();
    end({ method: req.method, route, code: res.statusCode });

    if (res.statusCode >= 400) {
      httpErrorCount.labels(req.method, route, res.statusCode).inc();
    }
  });
  next();
});

// Routes
const tripRoutes = require('./routes/trip.routes');
app.use('/trip', tripRoutes);

app.get('/hello', (req, res) => {
  res.send('Hello World!');
});

// --- Prometheus metrics endpoint ---
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err.message);
  }
});

app.listen(PORT, () => {
  console.log(`Server started at http://localhost:${PORT}`);
});
