#!/usr/bin/env bash
# 替换模板身份、Go 包名和目录；参数 name 为插件短名，例如 builtin。
set -euo pipefail

if [[ $# != 2 ]]; then
  echo "Usage: scripts/rename.sh <owner> <name>" >&2
  exit 1
fi
owner="$1"
name="$2"
if [[ ! "$owner" =~ ^[A-Za-z0-9]+(-[A-Za-z0-9]+)*$ ]] || [[ ! "$name" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
  echo "Owner must be a GitHub account; name must be a lowercase slug such as builtin or my-plugin" >&2
  exit 1
fi
package_name="${name//-/}"
case "$package_name" in
  break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var|main)
    echo "Name must produce a non-keyword Go library package" >&2
    exit 1
    ;;
esac

cd "$(dirname "$0")/.."
if ! grep -qx 'module github.com/OWNER/alonabot-plugin-example' go.mod; then
  echo "This script requires an unrenamed template" >&2
  exit 1
fi
if [[ "$name" != example && -e "cmd/alonabot-plugin-$name" ]] || [[ "$package_name" != example && -e "internal/$package_name" ]]; then
  echo "Destination directory already exists" >&2
  exit 1
fi

# 1. 只改源码、声明与公共文档，保留脚本自身的模板匹配串。
while IFS= read -r -d '' file; do
  sed -e "s|OWNER|$owner|g" \
      -e "s|alonabot-plugin-example|alonabot-plugin-$name|g" \
      -e "s|internal/example|internal/$package_name|g" \
      -e "s|package example|package $package_name|g" \
      -e "s|Package example|Package $package_name|g" \
      "$file" > "$file.rename-tmp"
  mv "$file.rename-tmp" "$file"
done < <(find . \( -name .git -o -name .codex -o -name .claude -o -name .serena -o -name .alonabot -o -name .idea -o -name .vscode -o -name data -o -name bin -o -name build -o -name dist -o -name tmp -o -name .worktrees -o -name .repo \) -prune -o \
  -type f \( -name '*.go' -o -name '*.md' -o -name '*.yml' -o -name '*.yaml' -o -name '*.json' -o -name go.mod -o -name LICENSE \) -print0)

# 2. 普通目录移动保持与替换后的 import 一致。
if [[ "$name" != example ]]; then
  mv cmd/alonabot-plugin-example "cmd/alonabot-plugin-$name"
fi
if [[ "$package_name" != example ]]; then
  mv internal/example "internal/$package_name"
fi
echo "Renamed to github.com/$owner/alonabot-plugin-$name (Go package: $package_name)"
