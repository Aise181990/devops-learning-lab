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