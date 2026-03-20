#!/bin/bash
set -e

echo "=== 安装推荐的 Claude Code 技能 ==="

# 1. Vercel 技能集
echo ">> 安装 Vercel find-skills（技能发现器）..."
npx skills add vercel-labs/skills --skill find-skills -g

echo ">> 安装 react-best-practices..."
npx skills add vercel-labs/agent-skills --skill react-best-practices -g

echo ">> 安装 frontend-design..."
npx skills add vercel-labs/agent-skills --skill frontend-design -g

# 2. 图像生成（需要 Gemini API Key）
echo ">> 安装 Gemini Image Gen（guinacio/claude-image-gen）..."
echo "   请手动安装：/plugin marketplace add guinacio/claude-image-gen"
echo "   或参见仓库 README：https://github.com/guinacio/claude-image-gen"

# 3. TTS（完全免费，本地运行）
echo ">> 安装 Kokoro TTS..."
if [ -d ~/.claude/hooks/claude-code-tts ]; then
  echo "   已存在，跳过"
else
  git clone https://git.sr.ht/~cg/claude-code-tts ~/.claude/hooks/claude-code-tts
  echo "   请按 README 完成 hook 配置"
fi

echo ""
echo "=== 安装完成 ==="
echo "提示："
echo "  - 图像生成需要 Gemini API Key：https://aistudio.google.com/apikey"
echo "  - TTS 需要按仓库 README 完成 hook 配置"
echo "  - 使用 'clawhub search' 发现更多技能"
