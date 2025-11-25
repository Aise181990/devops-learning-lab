# DevOps Fundamentals Exercise

## 🎯 Learning Objectives

This exercise introduces you to core DevOps concepts through a hands-on project:
- **Version Control**: Git workflow and branching
- **Containerization**: Docker basics and microservices
- **CI/CD**: GitHub Actions automation
- **Bash Commands**: Shell scripting fundamentals
- **Monitoring & Logging**: Basic observability
- **APIs**: Simple REST API interaction

## 📋 Prerequisites

- GitHub account - Your personal account
- GitHub Codespace (free tier works fine) - Create a manual codespace from the repository
- Basic understanding of command line

## 🚀 Exercise: Build a Containerized API with CI/CD

### Scenario
You'll create a simple Python API that returns system information, containerize it with Docker, and set up automated testing with GitHub Actions.

---

## Part 1: Git & Version Control (15 min)

### Tasks:
1. **Create a new repository** named `devops-learning-lab`
2. **Open in GitHub Codespace**
3. **Create a branch** for your work: 
   The ```bash ... ``` is just a .md extension convention to help you understand what type of shell to select to run the command - linux bash in our case.

```bash

git checkout -b feature/api-setup

```
✅ You should push it to Github if:

You want to save your work remotely.
You're collaborating and want others to see or review your changes.
You want to trigger GitHub Actions or other CI/CD workflows.
You're done with a feature and want to open a pull request.

❌ You don't need to push it to Github if:

You're just experimenting locally.
You haven't made any meaningful changes yet.
You're not ready to share or commit your work.


git add .
git commit -m "Your commit message"
git push origin feature/api-setup


---

## Part 2: Build a Simple API (20 min)

### Tasks:

1. **Create project structure**:

```bash

mkdir -p app logs
touch app/main.py app/requirements.txt

```

1. **Create `app/main.py`**:
   Just select the below content between ```python ... ``` and add it to the created `app/main.py` file

```python

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

```

3. **Create `app/requirements.txt`**:
Just select the below content between ``` ... ``` and add it to the created `app/requirements.txt` file

```

flask==3.0.0

```

1. **Test locally**:

```bash

cd app
pip install -r requirements.txt
python main.py

```

1. **Test the API** (in a new terminal) - Because we don't want to interrupt the current Flask server session!

```bash

curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/info

```

3. **Stop the Flask server** (press `Ctrl+C` in the terminal where it's running) before proceeding to Docker steps

4. **Check the logs**:

```bash

cat logs/app.log

```

---

## Part 3: Containerization with Docker (20 min)

### Tasks:

1. **Create `Dockerfile`**:
   
```dockerfile

# Use official Python runtime as base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Create logs directory
RUN mkdir -p /app/logs

# Expose port
EXPOSE 5000

# Set environment variable
ENV FLASK_APP=main.py

# Run the application
CMD ["python", "main.py"]

#Save the file 
CTRL + S
```

2. **Create `.dockerignore`**:

```
__pycache__
*.pyc
*.pyo
*.pyd
.Python
logs/*.log
.git
.gitignore

```
This tells Docker to ignore unnecessary files when building the image, which makes builds faster and cleaner.

1. **Build the Docker image**:

```bash

docker build -t devops-lab-api:v1 .

```

2. **Run the container**:

```bash

docker run -d -p 5000:5000 --name devops-api devops-lab-api:v1


1. **Test the containerized API**:

```bash

curl http://localhost:5000/health

``````

   **Note:** If you get a "port already in use" error, "curl: (7) Failed to connect to localhost port 5000 after 0 ms: Couldn't connect to server",
   This means the container is running, but the Flask app inside is not listening on the correct interface or not starting properly.

    stop the local Flask server or remove any existing container:
   ```bash
   # Remove existing container if needed
   docker rm -f devops-api
   # Then run the container again
   docker run -d -p 5000:5000 --name devops-api devops-lab-api:v1
   ```


1. **View container logs**:

```bash

docker logs devops-api
# ModuleNotFoundError: No module named 'flask'
# Readded flask==3.0.0 in app/requirements.txt

```

1. **Stop and remove container**:

```bash

docker stop devops-api
docker rm devops-api

```

---

## Part 4: Bash Scripting & Automation (15 min)

### Tasks:

1. **Create `scripts/deploy.sh`**:

```bash

#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Variables
IMAGE_NAME="devops-lab-api"
VERSION="${1:-latest}"
CONTAINER_NAME="devops-api"

# Stop and remove old container if exists
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
      echo "🛑 Stopping existing container..."
      docker stop $CONTAINER_NAME
      docker rm $CONTAINER_NAME
fi

# Build new image
echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME:$VERSION .

# Run new container
echo "▶️  Starting container..."
docker run -d -p 5000:5000 --name $CONTAINER_NAME $IMAGE_NAME:$VERSION

# Wait for container to be ready
echo "⏳ Waiting for API to be ready..."
sleep 3

# Health check
echo "🏥 Performing health check..."
RESPONSE=$(curl -s http://localhost:5000/health)

if echo "$RESPONSE" | grep -q "healthy"; then
      echo "✅ Deployment successful!"
      echo "📊 Response: $RESPONSE"
else
      echo "❌ Deployment failed!"
      exit 1
fi

```

2. **Make script executable**:
   
```bash

chmod +x scripts/deploy.sh

```

1. **Test the script**:
   
```bash

./scripts/deploy.sh v1.0

```

---

## Part 5: CI/CD with GitHub Actions (20 min)

### Tasks:

1. **Create `.github/workflows/ci.yml`**

# mkdir -p .github/workflows && touch .github/workflows/ci.yml

```yaml

name: CI/CD Pipeline

on:
   push:
      branches: [ main, feature/* ]
   pull_request:
      branches: [ main ]

jobs:
   test:
      runs-on: ubuntu-latest
      
      steps:
      - name: 🔍 Checkout code
      uses: actions/checkout@v4
      
      - name: 🐍 Set up Python
      uses: actions/setup-python@v4
      with:
         python-version: '3.11'
      
      - name: 📦 Install dependencies
      run: |
         pip install -r app/requirements.txt
         pip install pytest requests
      
      - name: 🧪 Run tests
      run: |
         echo "Running basic tests..."
         python -m pytest tests/ -v || echo "No tests found yet"
      
   build:
      needs: test
      runs-on: ubuntu-latest
      
      steps:
      - name: 🔍 Checkout code
      uses: actions/checkout@v4
      
      - name: 🔨 Build Docker image
      run: |
         docker build -t devops-lab-api:${{ github.sha }} .
      
      - name: 🧪 Test Docker container
      run: |
         docker run -d -p 5000:5000 --name test-api devops-lab-api:${{ github.sha }}
         sleep 5
         curl -f http://localhost:5000/health || exit 1
         docker stop test-api
         docker rm test-api
      
      - name: ✅ Build successful
      run: echo "Docker image built and tested successfully!"

```

2. **Create a simple test file `tests/test_api.py`**:

```python

import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app')))

from main import app
import pytest

@pytest.fixture
def client():
      app.config['TESTING'] = True
      with app.test_client() as client:
         yield client

def test_home(client):
      response = client.get('/')
      assert response.status_code == 200
      assert b"DevOps Learning Lab API" in response.data

def test_health(client):
      response = client.get('/health')
      assert response.status_code == 200
      assert b"healthy" in response.data

def test_info(client):
      response = client.get('/info')
      assert response.status_code == 200
      
```

3. **Commit and push your changes**:

```bash

git add .
git commit -m "feat: add containerized API with CI/CD"
git push origin feature/api-setup

```

1. **Create a Pull Request** on GitHub and watch the CI/CD pipeline run!

---

## Part 6: Monitoring & Observability (10 min)

### Tasks:

1. **Create a monitoring script `scripts/monitor.sh`**:

```bash

#!/bin/bash

echo "📊 DevOps Lab API Monitoring Dashboard"
echo "======================================"
echo ""

# Check if container is running
if [ "$(docker ps -q -f name=devops-api)" ]; then
      echo "✅ Container Status: RUNNING"
      
      # Get container stats
      echo ""
      echo "📈 Resource Usage:"
      docker stats devops-api --no-stream --format "  CPU: {{.CPUPerc}}\n  Memory: {{.MemUsage}}"
      
      # Check API health
      echo ""
      echo "🏥 API Health:"
      HEALTH=$(curl -s http://localhost:5000/health)
      echo "  $HEALTH"
      
      # Show recent logs
      echo ""
      echo "📝 Recent Logs (last 10 lines):"
      docker logs devops-api --tail 10
      
else
      echo "❌ Container Status: NOT RUNNING"
fi

```

2. **Make it executable and run**:

```bash

chmod +x scripts/monitor.sh
./scripts/monitor.sh

```

---

## 🎓 Learning Checkpoints

After completing this exercise, you should understand:

- ✅ **Git**: Creating branches, committing changes, push/pull workflow
- ✅ **Bash**: Writing shell scripts, using variables, conditionals
- ✅ **Docker**: Building images, running containers, viewing logs
- ✅ **APIs**: Creating REST endpoints, testing with curl
- ✅ **CI/CD**: Automated testing and building with GitHub Actions
- ✅ **Monitoring**: Checking health, viewing logs, resource usage
- ✅ **Logging**: Application logging for troubleshooting

---

## 🚀 Next Steps (Bonus Challenges)

1. **Add more tests** to `tests/test_api.py`
2. **Create a `docker-compose.yml`** to run multiple services
3. **Add environment variables** for configuration
4. **Implement a database** connection (SQLite)
5. **Add security scanning** to your CI/CD pipeline
6. **Create a monitoring dashboard** with metrics
7. **Implement rate limiting** on your API
8. **Add API documentation** with Swagger/OpenAPI

---

## 📚 Resources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Git Documentation](https://git-scm.com/doc)

---

## 🆘 Troubleshooting

**Container won't start?**

```bash

docker logs devops-api

```

**Port already in use?**

```bash

# Find process using port 5000
lsof -i :5000
# Or change port in commands: -p 5001:5000

```

**GitHub Actions failing?**
- Check the Actions tab in your repository
- Review the logs for each step
- Ensure all files are committed

---

**Happy DevOps Learning! 🎉**