
const express = require('express');
const cors = require('cors');
const promClient = require('prom-client'); // <-- Prometheus client
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

const conn = require('./conn');
const tripRoutes = require('./routes/trip.routes');

app.use(express.json());
app.use(cors());

// ---- Prometheus Metrics Setup ---- //
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics(); // Collect Node.js process metrics (CPU, memory, etc.)

// Custom metrics
const httpRequestCounter = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 3, 5] // latency buckets
});

const httpErrorCounter = new promClient.Counter({
  name: 'http_errors_total',
  help: 'Total number of failed HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// Middleware to record metrics
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const route = req.route ? req.route.path : req.path;
    const status = res.statusCode;
    httpRequestCounter.inc({ method: req.method, route, status });

    if (status >= 400) {
      httpErrorCounter.inc({ method: req.method, route, status });
    }

    end({ method: req.method, route, status });
  });
  next();
});

// ---- App Routes ---- //
app.use('/trip', tripRoutes); // http://localhost:3001/trip --> POST/GET/GET by ID

app.get('/hello', (req, res) => {
  res.send('Hello World!');
});

// ---- Prometheus Metrics Endpoint ---- //
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', promClient.register.contentType);
    const metrics = typeof promClient.register.metrics === 'function'
      ? await Promise.resolve(promClient.register.metrics())
      : promClient.register.metrics;
    res.end(metrics);
  } catch (err) {
    console.error('Metrics error:', err);
    res.status(500).end(err.message);
  }
});


// ---- Start Server ---- //
app.listen(PORT, () => {
  console.log(`Server started at http://localhost:${PORT}`);
});