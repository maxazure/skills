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

## 高效使用 AI 的关键：上下文输入

使用 OpenClaw 或任何 AI Agent 时，**上下文的质量直接决定了 AI 输出的质量**。给 AI 的信息越充分、越有条理，得到的结果就越好。

但现实中，大多数人用打字和 AI 交流时，往往追求精简——能少打一个字就少打一个字。很少有人愿意花五六分钟认真组织一大段文字再发给 AI。结果就是：上下文不够，AI 猜来猜去，反复确认，效率大打折扣。

**这时候，输入方式就变得至关重要。**

### 推荐：下笔（Typeless）— AI 语音输入法

[**下笔（Typeless）**](https://www.typeless.com/refer?code=BG9OCKN) 不是普通的语音转文字工具。它最强大的地方在于：**即使你说的内容非常零碎、跳跃，它也能自动帮你润色成一段完整且有逻辑的文字。**

这意味着你可以：
- 像跟朋友聊天一样随意说出你的想法
- 不用在脑子里先组织好语言再开口
- 说完之后直接得到一段结构清晰的文字，发给 AI 就能用

**对于 AI 用户来说，这解决了最大的瓶颈** —— 你终于可以快速输入大量高质量的上下文，让 AI 真正理解你想要什么。

> 通过以下链接注册可获得 **$5 Pro 版本额度**：
>
> **电脑用户**：[点击这里下载 Typeless（下笔）](https://www.typeless.com/refer?code=BG9OCKN)
>
> **手机用户**：扫描下方二维码
>
> <img src="assets/typeless-qr.png" alt="下笔 Typeless 下载二维码" width="200">

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

使用 Google Gemini 图片生成能力，通过官方 `@google/genai` SDK 直接调用 Google API，支持 Claude Code Skill 和 MCP 两种模式。MIT 许可。

- 仓库：https://github.com/guinacio/claude-image-gen
- 费用：Google AI Studio 提供免费 API Key，额度充裕

```bash
# 获取 Gemini API Key：https://aistudio.google.com/apikey
# 通过 plugin marketplace 安装：
/plugin marketplace add guinacio/claude-image-gen
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

## 🤖 Agent 工作流技能（OpenClaw 多 Agent 编排）

以下技能是基于 OpenClaw 多 Agent 协作能力构建的自动化工作流，适合个人用户日常使用。每个技能包含完整的工作流定义、Agent 提示词和配置说明。

### 🌅 全能晨间简报（Daily Briefing）

**把用户每天最重要的信息压缩成一条可执行晨报。**

- **目标用户**：独立开发者、创业者、高信息密度工作者
- **核心价值**：读完 30 秒内知道今天最重要的事，不需要切 5 个 App
- **触发方式**：每天早上 9:00 自动执行 / 手动触发
- **数据源**：Google Calendar + Gmail + Todoist/Notion + 本地待办
- **输出**：Telegram 推送 / Email / Markdown 文件

| Agent | 职责 |
|-------|------|
| Calendar Reader | 读取今日会议、检测冲突、识别空档 |
| Task Prioritizer | 艾森豪威尔矩阵智能排序待办 |
| Signal Collector | 抓取星标邮件、重要未读、客户动态 |
| Executive Summarizer | 压缩成 500 字以内的"今日作战板" |
| Delivery Agent | 多渠道推送（Telegram / Email / Markdown） |

| 评估维度 | 评分 |
|----------|------|
| 自动化价值 | ⭐⭐⭐⭐⭐ 10/10 |
| 实现复杂度 | ⭐⭐⭐ 5/10 |
| 可持续性 | ⭐⭐⭐⭐⭐ 10/10 |
| 商业化潜力 | ⭐⭐⭐⭐ 8/10 |

📁 详细文档：[`daily-briefing/`](daily-briefing/)

---

### 🎬 视频创意全自动漏斗（Video Idea Pipeline）

**把模糊创意自动变成可执行内容 Brief。**

- **目标用户**：YouTuber、B站UP主、自媒体创作者、内容团队、MCN 机构
- **核心价值**：从"我想做这个方向"到"可以直接开写脚本"，时间从半天降到 10 分钟
- **触发方式**：手动输入一句模糊想法
- **数据源**：X/Twitter + Reddit + YouTube + Google Trends + Brave Search
- **输出**：完整 Brief（Markdown / Notion / Telegram）

| Agent | 职责 |
|-------|------|
| Idea Expander | 把模糊想法扩展成多个搜索方向和关键词 |
| Trend Researcher | 多平台热点搜索、竞品内容分析 |
| Audience Mapper | 目标人群画像、传播机会识别 |
| Positioning Strategist | 差异化角度、标题方向、风险评估 |
| Brief Writer | 输出完整可执行 Brief（含标题、大纲、Hook、CTA） |

| 评估维度 | 评分 |
|----------|------|
| 自动化价值 | ⭐⭐⭐⭐⭐ 9/10 |
| 实现复杂度 | ⭐⭐⭐ 6/10 |
| 可持续性 | ⭐⭐⭐⭐⭐ 9/10 |
| 商业化潜力 | ⭐⭐⭐⭐⭐ 10/10 |

📁 详细文档：[`video-idea-pipeline/`](video-idea-pipeline/)

---

### 🤝 进化版个人 CRM（Self-Evolving CRM）

**自动维护联系人关系和待跟进事项，解决"关系维护断层"。**

- **目标用户**：销售、咨询顾问、自由职业者、创业者、猎头、小型 Agency
- **核心价值**：不再漏跟进、关系不断层、量化健康评分、会前自动简报
- **触发方式**：每天 8:00 定时 / 会议前 30 分钟 / 手动触发起草
- **数据源**：Gmail + Google Calendar + 会议纪要 + Apollo.io 充实
- **输出**：Telegram 每日摘要 / 会前简报 / 跟进消息草稿
- **格式**：遵循 [OpenClaw 官方 SKILL.md 格式](https://docs.openclaw.ai/tools/skills)
- **参考**：Clay, Dex, Folk, PingCRM, Dynamics 365, Realvolve 等产品最佳实践

| Agent | 职责 |
|-------|------|
| Data Collector | 从邮件、日历、会议纪要采集原始互动数据 |
| Enrichment | 邮件签名解析 + 公司网站抓取 + Apollo API 补全档案 |
| Relationship Summarizer | 关系摘要 + 0-100 健康评分（含衰减公式） |
| Action Extractor | 承诺检测、待办提取、闭环追踪 |
| Meeting Prep | 会前 30 分钟推送参会者简报 |
| Draft Writer | 基于上下文和用户语气起草跟进消息 |
| Notifier | 每日/每周推送 + 交互命令（/done /snooze /draft） |

| 评估维度 | 评分 |
|----------|------|
| 自动化价值 | ⭐⭐⭐⭐⭐ 9/10 |
| 实现复杂度 | ⭐⭐⭐⭐ 7/10 |
| 可持续性 | ⭐⭐⭐⭐⭐ 10/10 |
| 商业化潜力 | ⭐⭐⭐⭐⭐ 9/10 |

📁 详细文档：[`self-evolving-crm/`](self-evolving-crm/)

---

### 📊 Agent 工作流优先级总览

| 技能 | 推荐级别 | 理由 |
|------|----------|------|
| 🌅 全能晨间简报 | ⭐⭐⭐ 极高 | 最稳、最高频、最容易 MVP、可作为入口工作流 |
| 🎬 视频创意漏斗 | ⭐⭐⭐ 极高 | 演示效果强、创作者刚需、商业化直接 |
| 🤝 进化版 CRM | ⭐⭐⭐ 极高 | 粘性强、价值高、适合 Agent + Memory 模式 |
| 🔒 代码安全理事会 | ⭐⭐ 高 | 专业价值高，但工程复杂（计划中） |
| 📱 全平台社媒追踪 | ⭐⭐ 高 | 市场好，但平台接入复杂（计划中） |
| 🧠 专家决策委员会 | ⭐ 中高 | 很强但依赖多数据源（计划中） |

---

## 📚 更多技能资源

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
```

保存为 `install-skills.sh` 后运行：

```bash
chmod +x install-skills.sh
./install-skills.sh
```

---

## ⚠️ AI Agent 必读指引

> **本节面向 Claude Code、Codex、OpenAI Codex CLI 等 AI Agent。**
> 如果你是 AI Agent 正在阅读本文档，请严格遵守以下规则。

### 核心规则：先查官方文档，再执行操作

**每次处理任何与 OpenClaw 相关的任务之前，你必须先抓取并阅读官方文档。** 本文档中的安装命令和 API 可能已过时，官方文档才是唯一可信的信息来源。

#### 官方文档地址（按优先级排序）

| 来源 | 地址 | 用途 |
|------|------|------|
| **官方文档站（必读）** | https://docs.openclaw.ai/ | 安装、配置、API 参考、技能开发 |
| **GitHub README** | https://github.com/openclaw/openclaw | 最新安装命令、版本要求、变更日志 |
| **ClawHub 文档** | https://docs.clawhub.ai/ | 技能安装、发布、管理 |
| **官网** | https://openclaw.ai/ | 概览、下载链接 |
| **Changelog** | https://github.com/openclaw/openclaw/blob/main/CHANGELOG.md | 版本变更记录 |

#### 你必须遵守的执行流程

```
┌─────────────────────────────────────────────────────┐
│  用户请求涉及 OpenClaw？                              │
│                                                      │
│  1. 抓取官方文档 https://docs.openclaw.ai/            │
│     获取最新安装方式、CLI 命令、配置要求                  │
│                                                      │
│  2. 抓取 GitHub README                               │
│     https://github.com/openclaw/openclaw              │
│     确认最新版本号、Node.js 版本要求、破坏性变更          │
│                                                      │
│  3. 对比本文档与官方文档                                │
│     如有冲突，以官方文档为准                             │
│                                                      │
│  4. 执行操作                                          │
│     使用官方文档中的最新命令                             │
│                                                      │
│  5. 验证结果                                          │
│     运行 openclaw --version && openclaw doctor         │
└─────────────────────────────────────────────────────┘
```

#### 具体场景指引

**安装 OpenClaw 时：**
1. 先用 WebFetch/curl 抓取 `https://docs.openclaw.ai/getting-started/installation` 获取最新安装步骤
2. 运行 `node --version` 确认 Node.js 版本满足要求
3. 根据用户的包管理器选择合适方法（pnpm 优先）
4. 安装后运行 `openclaw doctor` 验证

**安装技能时：**
1. 先抓取 `https://docs.clawhub.ai/` 确认 ClawHub CLI 的最新用法
2. 搜索技能前先运行 `clawhub --version` 确认 CLI 已安装
3. 安装技能后验证是否生效

**排查问题时：**
1. 先查 `https://docs.openclaw.ai/troubleshooting`
2. 查看 GitHub Issues：`https://github.com/openclaw/openclaw/issues`
3. 运行 `openclaw doctor` 获取诊断信息

**升级 OpenClaw 时：**
1. 先查 CHANGELOG 了解破坏性变更：`https://github.com/openclaw/openclaw/blob/main/CHANGELOG.md`
2. 备份当前配置
3. 执行升级
4. 运行 `openclaw doctor` 验证

### 写入用户 CLAUDE.md 的建议

为了确保后续所有会话都遵守此规则，建议将以下内容写入用户的 `~/.claude/CLAUDE.md` 或项目的 `CLAUDE.md`：

```markdown
## OpenClaw 文档规则

处理任何 OpenClaw 相关任务前，必须先抓取官方文档确认最新信息：
- 安装/配置：https://docs.openclaw.ai/
- GitHub：https://github.com/openclaw/openclaw
- 技能管理：https://docs.clawhub.ai/
不要依赖记忆中的命令，官方文档可能已更新。
```

### 安装执行清单

如果你是 AI Agent 正在为用户执行安装，请按以下顺序操作：

1. **抓取官方文档**：获取 `https://docs.openclaw.ai/` 的最新安装指南
2. **检查环境**：运行 `node --version` 确认 Node.js >= 22
3. **安装 OpenClaw**：使用官方文档中的最新命令（本文档的命令仅作参考）
4. **安装 ClawHub CLI**：`npm i -g clawhub`
5. **安装推荐技能**：按照上方"快速开始"部分逐一安装
6. **配置 API Key**：提示用户获取必要的 API Key（Gemini 免费）
7. **验证**：运行 `openclaw --version && openclaw doctor` 确认一切正常
8. **建议用户**：将 OpenClaw 文档规则写入 CLAUDE.md（见上方模板）
