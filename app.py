from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics
import random
import time

app = Flask(__name__)

metrics = PrometheusMetrics(app)

metrics.info('app_info',
             'Application info, created for demo purposes randomly',
             version='1.0.0')

@app.route('/')
def home():
    """Root endpoint"""
    return jsonify({
        "message": "Welcome to the demo monitoring app",
        "endpoints": {
        "/": "App root",
        "/api/data": "Returns random data",
        "/api/slow": "Simulates slow requests",
        "/heath": "Health check endpoint",
        "/metrics": "Prometheus metrics"
    }
    })

@app.route('/api/data')
def get_data():
    """Returns random data"""
    data = {
        "value": random.randint(1, 100),
        "timestamp": time.time()
    }
    return jsonify(data)

@app.route('/api/slow')
def slow_endpoint():
    """Returns random data but slowly"""
    delay = random.uniform(1, 3)
    time.sleep(delay)
    return jsonify({
        "message": "This was a slow request",
        "delay_seconds": delay
    })

@app.route('/health')
def health_check():
    """Healthcheck endpoint"""
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)