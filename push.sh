#!/bin/bash
# Session2Blog — GitHub 发布脚本（本地运行）
# 用法：
#   1. 修改下面的 GITHUB_USER 为你的 GitHub 用户名
#   2. 选一种认证方式：
#      A) 用 gh CLI（推荐）：先 `gh auth login`，然后直接跑本脚本
#      B) 用 token：取消注释 TOKEN 行，填入你的 personal access token（push 后去 GitHub 撤销）
#   3. bash push.sh

set -euo pipefail

GITHUB_USER="jasonleezy"          # ← 改成你的 GitHub 用户名
REPO_NAME="session2blog"
REMOTE="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"

# 方式 B（token）需要时在下面填，用完去 GitHub 撤销：
# TOKEN="ghp_xxxxxxxxxxxx"
# REMOTE="https://${TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

cd "$(dirname "$0")"

# 初始化（如果还没 init）
if [ ! -d .git ]; then
  git init
  git branch -M main
fi

# 添加 remote（已存在则更新）
if git remote | grep -q "^origin$"; then
  git remote set-url origin "$REMOTE"
else
  git remote add origin "$REMOTE"
fi

git add .
git commit -m "Session2Blog v1.1: platform-specific styles + auto-redaction"
git push -u origin main

echo ""
echo "✅ 推送完成！"
echo "👉 仓库地址: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "⚠️  如果你用了 token，现在去 GitHub → Settings → Developer settings → PAT → Revoke 它"
