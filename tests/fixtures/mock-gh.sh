#!/bin/sh
# Mock gh CLI: makes 'gh auth setup-git' a no-op for local file:// URL testing
if [ "$1" = "auth" ] && [ "$2" = "setup-git" ]; then
  echo "Mock: gh auth setup-git (no-op for file:// URLs)"
  exit 0
fi
exec /usr/bin/gh "$@"
