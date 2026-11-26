#!/usr/bin/env bash
# 校验组件身份，打包五平台归档并从双语 changelog 生成发布说明。
# 用法：scripts/release.sh v0.1.0 OWNER/alonabot-plugin-example
set -euo pipefail

if [[ $# != 2 ]]; then
  echo "Usage: scripts/release.sh <tag> <owner/repo>" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
tag="$1"
repo="$2"
targets=(linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64)
version="$(sed -n 's/^version: *//p' plugin.yaml)"
source="$(sed -n 's/^source: *//p' plugin.yaml)"

# 1. 发布输入必须与工程身份、版本记录一致。
if [[ "$tag" != "v$version" ]]; then
  echo "tag $tag does not match plugin.yaml version $version" >&2
  exit 1
fi
if [[ "$source" != "github.com/$repo" ]]; then
  echo "plugin.yaml source $source does not match github.com/$repo" >&2
  exit 1
fi
for locale in en-US zh-CN; do
  if [[ ! -s "changelog/$version/$locale.md" ]]; then
    echo "Missing release notes: changelog/$version/$locale.md" >&2
    exit 1
  fi
done

# 2. 每次使用干净的打包目录，防止上传旧版本资产。
rm -rf dist
args=()
for target in "${targets[@]}"; do
  args+=(--target "$target")
done
alonabot pack . "${args[@]}" --out dist
for archive in dist/*.tar.gz; do
  if ! tar -tzf "$archive" | grep -x LICENSE > /dev/null; then
    echo "Archive is missing LICENSE: $archive" >&2
    exit 1
  fi
done

# 3. 保留 fenced code，省略版本标题，将分类统一为三级标题。
{
  for locale in en-US zh-CN; do
    if [[ "$locale" == en-US ]]; then
      printf '## English\n\n'
    else
      printf '\n## 简体中文\n\n'
    fi
    awk '
      /^ {0,3}(`{3,}|~{3,})/ {
        marker = $0; sub(/^ */, "", marker)
        character = substr(marker, 1, 1)
        sub(character == "`" ? "[^`].*$" : "[^~].*$", "", marker)
        if (!fence) { fence = character; width = length(marker) }
        else if (character == fence && length(marker) >= width && $0 ~ ("^ *" fence "+[[:space:]]*$")) { fence = "" }
        print; next
      }
      !fence && !version && /^#{1,2} / { version = 1; next }
      !fence && /^#{1,6} / { sub(/^#+ /, "### ") }
      { print }
    ' "changelog/$version/$locale.md"
  done
} > dist/notes.md
