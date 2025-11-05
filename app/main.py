from flask import Flask, jsonify
import os
import datetime
import logging

app = Flask(__name__)

# Configure logging
log_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'logs')
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, 'app.log')

logging.basicConfig(
      level=logging.INFO,
      format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
      handlers=[
         logging.FileHandler(log_file),
         logging.StreamHandler()
      ]
)
logger = logging.getLogger(__name__)

@app.route('/')
def home():
      logger.info("Home endpoint accessed")
      return jsonify({
         "message": "Starting DevOps with IT TechGuide Mentoring Sessions is so cool and fancy!",
         "version": "1.0.0"
      })

@app.route('/health')
def health():
      logger.info("Health check performed")
      return jsonify({
         "status": "healthy",
         "timestamp": datetime.datetime.now().isoformat(),
         "hostname": os.getenv("HOSTNAME", "unknown")
      })

@app.route('/info')
def info():
      logger.info("System info requested")
      return jsonify({
         "python_version": os.sys.version,
         "platform": os.sys.platform,
         "user": os.getenv("USER", "unknown")
      })

if __name__ == '__main__':
      logger.info("Starting DevOps with IT TechGuide Mentoring Sessions is so cool and fancy!")
      app.run(host='0.0.0.0', port=5000, debug=True)