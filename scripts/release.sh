#!/usr/bin/env bash
# 为五个目标平台生成组件归档，从 CHANGELOG.md 取出本版本的说明。
# 用法：scripts/release.sh v0.1.0 owner/repo
# 输出：dist/ 下的归档与 notes.md。
set -euo pipefail

tag="$1"
repo="$2"
targets=(linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64)

version="$(sed -n 's/^version: *//p' plugin.yaml)"
source="$(sed -n 's/^source: *//p' plugin.yaml)"

if [[ "$tag" != "v$version" ]]; then
  echo "tag $tag does not match plugin.yaml version $version" >&2
  exit 1
fi
if [[ "$source" != "github.com/$repo" ]]; then
  echo "plugin.yaml source $source does not match github.com/$repo" >&2
  exit 1
fi

rm -rf dist
args=()
for target in "${targets[@]}"; do
  args+=(--target "$target")
done
alonabot pack . "${args[@]}" --out dist

# 取出 CHANGELOG.md 中「## [版本]」到下一个「## [」之间的内容作为发布说明。
awk -v v="$version" '
  $0 ~ "^## \\[" v "\\]" { found = 1; next }
  found && /^## \[/ { exit }
  found { print }
' CHANGELOG.md > dist/notes.md
if [[ ! -s dist/notes.md ]]; then
  echo "CHANGELOG.md has no section for $version" >&2
  exit 1
fi
