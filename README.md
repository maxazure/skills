# OpenClaw 安装指南 & 技能集合

> 让你的 AI 助手（Claude Code / Codex）阅读本文档，即可自动完成 OpenClaw 安装和技能配置。

## 什么是 OpenClaw？

OpenClaw 是一个开源（MIT）的个人 AI 助手平台，可以在你的电脑上本地运行，连接 WhatsApp、Telegram、Discord、iMessage 等 20+ 消息平台。它支持持久记忆、浏览器控制、语音交互、定时任务等功能，拥有 5,700+ 社区技能。

- 官网：https://openclaw.ai/
- GitHub：https://github.com/openclaw/openclaw
- 文档：https://docs.openclaw.ai/
- 技能市场（ClawHub）：https://clawhub.ai/

---

## 安装 OpenClaw

### 环境要求

- **Node.js** >= 22（推荐 Node 24）
- **操作系统**：macOS / Linux / Windows (WSL2)

### 方法 1：一键安装（推荐）

```bash
# macOS / Linux / WSL2
curl -fsSL https://openclaw.ai/install.sh | bash

# Windows PowerShell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

### 方法 2：npm 安装

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

### 方法 3：pnpm 安装

```bash
pnpm add -g openclaw@latest
pnpm approve-builds -g
openclaw onboard --install-daemon
```

### 方法 4：从源码安装

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install && pnpm ui:build && pnpm build
pnpm link --global
openclaw onboard --install-daemon
```

### 方法 5：Docker

```bash
docker pull openclaw/openclaw:latest
docker run -d --name openclaw -p 3000:3000 openclaw/openclaw:latest
```

### 验证安装

```bash
openclaw --version
openclaw doctor
openclaw gateway status
```

> **注意**：OAuth 认证已于 2026 年 1 月关闭，目前唯一支持的认证方式是 **Anthropic API Key**（按量付费）。

---

## 安装 ClawHub CLI（技能管理器）

```bash
npm i -g clawhub
```

常用命令：

```bash
clawhub search "关键词"           # 搜索技能
clawhub install <skill-slug>     # 安装技能
clawhub update --all             # 更新所有技能
clawhub list                     # 查看已安装技能
```

---

## 推荐技能合集（免费 & 个人用户友好）

以下技能均为免费或有免费额度，适合个人用户日常使用。

---

### 🎙️ 语音合成（TTS）

#### Kokoro TTS — 完全免费，本地运行

使用 Kokoro TTS 模型（82M 参数）在本地生成语音，完全离线，无需 API Key。Apple Silicon 上运行流畅。

- 仓库：https://git.sr.ht/~cg/claude-code-tts
- 备选实现：https://github.com/tcmartin24/claude-tts（Qwen3-TTS + Apple MLX，9 种声音）

```bash
# 克隆仓库后按 README 配置为 Claude Code hook
git clone https://git.sr.ht/~cg/claude-code-tts ~/.claude/hooks/claude-code-tts
cd ~/.claude/hooks/claude-code-tts
# 按仓库 README 完成配置
```

#### VoiceMode MCP — 完整语音交互方案

本地 Whisper 语音识别 + Kokoro TTS 语音合成，可直接与 Claude 对话。

- 官网：https://getvoicemode.com/

```bash
voicemode whisper install   # 安装本地语音识别
voicemode kokoro install    # 安装本地语音合成
```

#### ElevenLabs TTS — 高质量语音（有免费额度）

- 仓库：https://github.com/glebis/claude-skills（elevenlabs-tts 子目录）

```bash
npx playbooks add skill glebis/claude-skills --skill elevenlabs-tts
# 或手动安装：
mkdir -p ~/.claude/skills/elevenlabs-tts
cd ~/.claude/skills/elevenlabs-tts
# 从仓库复制文件，配置 ElevenLabs API Key
```

---

### 🎨 图像生成

#### Gemini Image Gen — 推荐，Google 免费 API

使用 Google Gemini 图片生成能力，支持 Claude Code Skill 和 MCP 两种模式。

- 仓库：https://github.com/guinacio/claude-image-gen
- 费用：Google AI Studio 提供免费 API Key，额度充裕

```bash
# 获取 Gemini API Key：https://aistudio.google.com/apikey
# 通过 plugin marketplace 安装：
/plugin marketplace add guinacio/claude-image-gen
```

#### Gemini Image Skill（备选实现）

- 仓库：https://github.com/Ceeon/gemini-image-skill

```bash
git clone https://github.com/Ceeon/gemini-image-skill.git /tmp/gemini-image-skill
cp -r /tmp/gemini-image-skill ~/.claude/skills/gemini-image
cd ~/.claude/skills/gemini-image
cp secrets.example.md secrets.md
# 编辑 secrets.md，填入 Gemini API Key
```

---

### 🛠️ 开发效率

#### Vercel 官方技能集 — 最高安装量

- 仓库：https://github.com/vercel-labs/agent-skills
- 官网：https://skills.sh

```bash
# React/Next.js 最佳实践（185K+ 安装）
npx skills add vercel-labs/agent-skills --skill react-best-practices -g

# 前端设计技能
npx skills add vercel-labs/agent-skills --skill frontend-design -g

# 技能发现器 — 让 Claude 自动搜索合适的技能
npx skills add vercel-labs/skills --skill find-skills -g
```

#### Firecrawl — 网页抓取 & 搜索

将任意网页转为 Markdown、截图、结构化数据提取。

- 仓库：https://github.com/firecrawl/firecrawl-claude-plugin
- 费用：有免费额度

```bash
# 作为 Claude Code plugin 安装
# 参见仓库 README
```

---

### 📚 更多技能资源

| 资源 | 地址 | 说明 |
|------|------|------|
| Awesome Claude Skills | https://github.com/travisvn/awesome-claude-skills | 最知名的精选列表 |
| Awesome Agent Skills | https://github.com/VoltAgent/awesome-agent-skills | 500+ 跨平台技能 |
| ClawHub 市场 | https://clawhub.ai/ | OpenClaw 官方技能市场 |
| ClawSkills 目录 | https://clawskills.sh/ | 社区技能目录 |
| Skills.sh | https://skills.sh | Vercel 技能目录 |

---

## 快速开始：一键安装推荐技能

以下脚本会自动安装上述推荐的免费技能：

```bash
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
echo ">> 安装 Gemini Image Skill..."
if [ -d ~/.claude/skills/gemini-image ]; then
  echo "   已存在，跳过"
else
  git clone https://github.com/Ceeon/gemini-image-skill.git /tmp/gemini-image-skill
  cp -r /tmp/gemini-image-skill ~/.claude/skills/gemini-image
  echo "   请编辑 ~/.claude/skills/gemini-image/secrets.md 填入 Gemini API Key"
fi

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
```

保存为 `install-skills.sh` 后运行：

```bash
chmod +x install-skills.sh
./install-skills.sh
```

---

## 给 AI 助手的指引

如果你是 Claude Code 或 Codex，正在为用户执行安装：

1. **先检查环境**：运行 `node --version` 确认 Node.js >= 22
2. **安装 OpenClaw**：根据用户的包管理器选择合适的方法（pnpm 优先）
3. **安装 ClawHub CLI**：`npm i -g clawhub`
4. **安装推荐技能**：按照上方"快速开始"部分逐一安装
5. **配置 API Key**：提示用户获取必要的 API Key（Gemini 免费）
6. **验证**：运行 `openclaw doctor` 确认一切正常
