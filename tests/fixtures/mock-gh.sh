#!/bin/sh
# Mock gh: intercept auth setup-git, pass everything else through
case "$1 $2" in
  "auth setup-git")
    echo "Mock gh: auth setup-git intercepted (no-op)"
    exit 0
    ;;
esac
exec /usr/bin/gh "$@"
