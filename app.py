from flask import Flask, jsonify, request
from prometheus_flask_exporter import PrometheusMetrics
import random
import time
import logging, logging.config

app = Flask(__name__)

metrics = PrometheusMetrics(app)

metrics.info('app_info',
             'Application info, created for demo purposes randomly',
             version='1.0.0')

logging_dict_config = {
    'version': 1,
    'formatters':
        {'default': {
            'format': '%(asctime)s module=%(module)s level=%(levelname)s: %(message)s',
        }},
    'handlers': {
        'file': {
            'class': 'logging.FileHandler',
            'filename': '/var/tmp/flask-app.log',
            'formatter': 'default',
            'level': 'INFO'
        },
        'stream': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
            'stream': 'ext://sys.stdout'
        }
    },
    'loggers': {
        'app': {
            'level': 'INFO',
            'handlers': ['file', 'stream']
        },
        'werkzeug._internal': {
            'level': 'WARNING'
        }
    }
}

logging.config.dictConfig(logging_dict_config)

logging.getLogger('werkzeug._internal').setLevel(logging.WARNING)

logger = logging.getLogger('app')


@app.errorhandler(404)
def not_found(e):
    """Handler if endpoint pinged not found"""
    logger.warning(f'GET request on non-existent endpoint {request.path} from {request.access_route[0]}')
    return "404 Resource not found.", 404


@app.after_request
def log_response(response):
    logger.info(f'{request.method} {response.status_code} {request.path} from {request.access_route[0]}')
    return response
@app.route('/')
def home():
    """Root endpoint"""
    return jsonify({
        "message": "Welcome to the demo monitoring app",
        "endpoints": {
            "/": "App root",
            "/api/data": "Returns random data",
            "/api/slow": "Simulates slow requests",
            "/health": "Health check endpoint",
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
