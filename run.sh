#!/usr/bin/env bash
# Starts the infinite idea loop as a background daemon process.
set -euo pipefail
cd "$(dirname "$0")"

if [ -f .loop.pid ] && kill -0 "$(cat .loop.pid)" 2>/dev/null; then
  echo "Loop already running (PID $(cat .loop.pid)). Not starting a second instance."
  exit 0
fi

rm -f STOP
mkdir -p logs

# Use system python3 directly (no uv build system)
nohup python3 core/loop.py >> logs/loop.log 2>&1 &
echo $! > .loop.pid
echo "Started Gaming AI Scientist loop (PID $(cat .loop.pid)). Logs: logs/loop.log"
