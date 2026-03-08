const express = require("express");
const client = require("prom-client");

const app = express();
app.disable("x-powered-by");

const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || "dev";
const NODE_ENV = process.env.NODE_ENV || "development";

// Prometheus metrics
client.collectDefaultMetrics({ prefix: "api_" });
const httpRequestDurationMs = new client.Histogram({
  name: "api_http_request_duration_ms",
  help: "Duration of HTTP requests in ms",
  labelNames: ["method", "route", "status_code"],
  buckets: [5, 10, 25, 50, 100, 250, 500, 1000, 2000]
});

function metricsMiddleware(req, res, next) {
  const end = httpRequestDurationMs.startTimer();
  res.on("finish", () => {
    // Express route may be undefined if no match
    const route = req.route?.path || req.path || "unknown";
    end({ method: req.method, route, status_code: String(res.statusCode) });
  });
  next();
}

app.use(metricsMiddleware);

app.get("/health", (req, res) => res.status(200).send("ok"));
app.get("/ready", (req, res) => res.status(200).send("ready"));

app.get("/api/message", (req, res) => {
  res.json({
    message: "Hello from Node.js API",
    version: APP_VERSION,
    env: NODE_ENV,
    time: new Date().toISOString()
  });
});

app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", client.register.contentType);
    res.end(await client.register.metrics());
  } catch (e) {
    res.status(500).json({ error: "metrics_error" });
  }
});

// Nice for ALB health check too (optional)
app.get("/", (req, res) => res.status(200).send("api"));

app.listen(PORT, () => {
  console.log(JSON.stringify({ msg: "api_started", port: PORT, version: APP_VERSION, env: NODE_ENV }));
});