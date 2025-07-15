#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: This script must be run as root (using sudo)"
  echo "Please run: sudo $0"
  exit 1
fi

echo "start updating apps 🚀"
apt-get update
echo "updated package lists successfully! ✅"
apt-get full-upgrade -y
echo "upgraded all packages successfully! ✅"
apt-get clean
apt-get autoremove
apt-get autoclean
echo "cleaned up unnecessary packages! 🧹"
echo "all apps are up to date! 🎉"
