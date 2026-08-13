#!/bin/sh
# Mock git: intercept .wiki.git clone/fetch/push, pass everything else through

args_have_wiki() {
  for a in "$@"; do
    case "$a" in
      *.wiki.git*) return 0 ;;
    esac
  done
  return 1
}

origin_is_wiki() {
  remote_url=$(/usr/bin/git remote get-url origin 2>/dev/null) || return 1
  case "$remote_url" in
    *.wiki.git*) return 0 ;;
  esac
  return 1
}

case "$1" in
  clone)
    if args_have_wiki "$@"; then
      wiki_url="$2"
      # Find destination: last arg that isn't a flag
      dest="."
      for a in "$@"; do
        case "$a" in
          -*) ;;
          *) dest="$a" ;;
        esac
      done
      # If dest is the URL itself, use "."
      case "$dest" in
        *.wiki.git*) dest="." ;;
      esac
      if [ "$dest" != "." ]; then
        mkdir -p "$dest"
        cd "$dest" || exit 1
      fi
      /usr/bin/git init -b master
      /usr/bin/git config user.email "test@example.com"
      /usr/bin/git config user.name "Test User"
      /usr/bin/git commit --allow-empty -m "init wiki"
      /usr/bin/git remote add origin "$wiki_url"
      exit 0
    fi
    ;;
  fetch)
    if args_have_wiki "$@" || origin_is_wiki; then
      echo "From mock-wiki (fetch intercepted)"
      exit 0
    fi
    ;;
  push)
    if args_have_wiki "$@" || origin_is_wiki; then
      echo "To mock-wiki (push intercepted)"
      exit 0
    fi
    ;;
esac

exec /usr/bin/git "$@"
