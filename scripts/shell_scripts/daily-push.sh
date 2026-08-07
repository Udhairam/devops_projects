#!/bin/bash
# Daily DevOps activity log — runs via launchd every morning

REPO_DIR="/Users/udhairam/Documents/my_workspace/devops_projects"
LOG_DIR="$REPO_DIR/daily-log"
DATE=$(date +"%Y-%m-%d")
DAY=$(date +"%A")
LOG_FILE="$LOG_DIR/$DATE.md"
PUSH_LOG="$HOME/.daily-push.log"

exec >> "$PUSH_LOG" 2>&1
echo "==== $DATE $(date +%H:%M:%S) ===="

cd "$REPO_DIR" || { echo "ERROR: repo dir not found"; exit 1; }

# Skip if today's log already exists and was already pushed
if git log --oneline --since="$DATE 00:00" | grep -q "$DATE"; then
  echo "Already pushed today. Skipping."
  exit 0
fi

# Create today's log entry if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
  cat > "$LOG_FILE" <<EOF
# DevOps Log — $DATE ($DAY)

## Focus Area
<!-- e.g. Terraform, Kubernetes, CI/CD, Networking, Monitoring -->

## What I worked on
-

## Key learnings
-

## Resources
-

## Tomorrow
-
EOF
fi

git add "$LOG_FILE"
git commit -m "chore: daily log $DATE"
git push origin main

echo "Pushed successfully."
