# Daily Briefing — 零 API 本地晨间简报

> 把用户每天最重要的信息压缩成一条可执行晨报。零 API 密钥、零配置、完全本地化。

---

## 概述

Daily Briefing 是 OpenClaw 平台上的个人助理技能。它在每天早上自动聚合你的日历、待办事项、RSS 新闻和天气等信息源，经过 AI 智能筛选和优先级排序后，生成一份 **30 秒内可读完** 的晨间简报，保存为本地 Markdown 文件。

**核心理念**：你不需要每天早上打开 5 个 App 才能知道今天该干什么。一份文件，全部搞定。

**最大亮点**：**零 API 密钥**。不需要 Google OAuth、不需要 Todoist Token、不需要 Telegram Bot——所有数据源都是本地工具或免费公开服务。

---

## 目标用户

- **独立开发者**：每天在代码、客户、产品之间切换，需要快速理清优先级
- **创业者 / Solo Founder**：信息源多且杂，容易遗漏重要事项
- **高信息密度工作者**：会议多、待办多，需要一个"每日作战板"

---

## 核心价值

| 痛点 | Daily Briefing 的解决方式 |
|------|--------------------------|
| 每天早上要打开日历、待办、新闻... | 一份文件汇总所有 |
| 不知道今天最重要的事是什么 | AI 自动排出 Top 3 优先级 |
| 会议冲突没注意到 | 自动检测并预警 |
| 过期任务越积越多 | 主动提醒 overdue 事项 |
| 不知道今天天气如何 | 自动获取当地天气 |
| API 配置太复杂 | 零 API 密钥，开箱即用 |

---

## 数据源对比

| 数据 | 传统方案（需 API） | 本技能方案（零 API） |
|------|-------------------|---------------------|
| 日历 | Google Calendar API + OAuth | `icalBuddy`（macOS 原生日历读取） |
| 待办 | Todoist / Notion API | `~/todos/*.md` 本地 Markdown |
| 信号/新闻 | Gmail API | RSS 订阅 + 可选 Browser Use MCP |
| 天气 | Weather API + Key | `curl wttr.in`（免费公开） |
| 推送 | Telegram Bot API | 本地 Markdown 文件 |

---

## 工作流概述

本技能由 5 个 Agent 协同完成，按流水线顺序执行：

```
┌─────────────┐   ┌──────────────┐   ┌────────────────┐
│ 1. Calendar  │   │ 2. Task      │   │ 3. Signal      │
│    Reader    │   │    Prioritizer│   │    Collector    │
│ icalBuddy   │   │ ~/todos/*.md │   │ RSS + 天气      │
└──────┬───────┘   └──────┬───────┘   └───────┬────────┘
       │                  │                    │
       └──────────────────┼────────────────────┘
                          ▼
              ┌───────────────────────┐
              │ 4. Executive          │
              │    Summarizer         │
              │ 压缩成"今日作战板"     │
              └───────────┬───────────┘
                          ▼
              ┌───────────────────────┐
              │ 5. Delivery Agent     │
              │ 保存为本地 Markdown    │
              └───────────────────────┘
```

| Agent | 职责 | 输入 | 输出 |
|-------|------|------|------|
| Calendar Reader | 读取今日会议、识别冲突、找出空档 | icalBuddy 命令输出 | 会议列表 + 冲突警告 + 空闲时段 |
| Task Prioritizer | 读取待办并智能排序 | 本地 Markdown (`~/todos/*.md`) | 按优先级排序的任务列表（Top 3-5） |
| Signal Collector | 收集重要信号和新闻 | RSS 订阅 + wttr.in 天气 + 可选浏览器 | 重要信号列表 + 天气数据 |
| Executive Summarizer | 压缩成可执行晨报 | 前三个 Agent 的输出 | daily_brief YAML 结构（含天气） |
| Delivery Agent | 格式化并保存 | 晨报内容 | 本地 Markdown 文件 |

---

## 安装配置

### 1. 安装 icalBuddy（必需）

```bash
brew install ical-buddy
```

验证安装：

```bash
icalBuddy eventsToday
```

如果你的 macOS 日历中有事件，应该能看到今日的会议列表。

> 注意：首次运行时 macOS 可能会弹出日历访问权限提示，请允许。

### 2. 创建待办目录（推荐）

```bash
mkdir -p ~/todos
```

在该目录下创建 Markdown 待办文件，格式：

```markdown
# 工作待办

- [ ] 完成客户报价方案 📅 2026-03-28
- [ ] Review PR #42 ⚡
- [x] 更新文档（已完成，会被忽略）
- [ ] 续期 SSL 证书 📅 2026-03-25

# 个人待办

- [ ] 预约牙医
```

### 3. 配置 RSS 订阅（可选）

```bash
mkdir -p ~/daily-briefing-config
```

创建 `~/daily-briefing-config/feeds.yml`：

```yaml
feeds:
  - name: "Hacker News 精选"
    url: "https://hnrss.org/best"
    category: tech

  - name: "Google News - AI"
    url: "https://news.google.com/rss/search?q=AI&hl=zh-CN"
    category: ai

  - name: "Google News - NZ"
    url: "https://news.google.com/rss/search?q=New+Zealand&hl=en-NZ"
    category: local

  # 添加你关注的其他 RSS 源
```

### 4. Browser Use MCP（可选，高级功能）

如果你需要浏览器自动化（例如读取 Gmail 网页版），可以添加 Browser Use MCP：

```bash
claude mcp add browser-use -- uvx --from 'browser-use[cli]' browser-use --mcp
```

这是完全可选的。基础功能只需要 icalBuddy + 本地 Markdown + RSS。

---

## 输出示例

```yaml
daily_brief:
  date: "2026-03-28"
  weather: "多云 +18°C 微风 湿度72%"
  today_in_one_sentence: "上午有两个连续会议，下午是深度工作窗口，客户报价今天必须发出。"

  top_priorities:
    - "发出客户报价方案（截止 18:00）"
    - "Review PR #42 — 阻塞了下游部署"
    - "续期 SSL 证书（已逾期 3 天）"

  meetings:
    - time: "09:30-10:00"
      title: "周五站会"
      attendees: ["团队全员"]
      notes: "准备本周进度汇报"
    - time: "10:00-11:00"
      title: "客户需求对齐"
      attendees: ["李总", "产品组"]
      notes: "与站会背靠背，无缓冲时间"

  conflict_alerts:
    - "09:30-11:00 连续两个会议，建议站会提前 5 分钟结束"

  free_slots:
    - "11:00-12:00（1h 空档）"
    - "14:00-17:30（3.5h 深度工作窗口）"

  urgent_followups:
    - source: "RSS/Hacker News"
      summary: "OpenAI 发布 GPT-5，可能影响产品路线图"
      urgency: "medium"

  risk_alerts:
    - "客户报价方案今天截止，目前还没有开始写"
    - "本周已有 3 个 overdue 任务未处理"

  suggested_focus: "上午处理会议，下午 14:00 后进入深度工作模式，专注完成客户报价方案"
```

输出文件保存在 `~/daily-briefs/2026-03-28.md`。

---

## 难点与风险

### 简化后的风险评估

由于去掉了所有外部 API 依赖，本技能的实现难度和风险大幅降低：

| 维度 | 评估 |
|------|------|
| **安装难度** | 极低 — 只需 `brew install ical-buddy` |
| **配置复杂度** | 极低 — 无需 OAuth、无需 Token |
| **运行稳定性** | 极高 — 所有数据源都是本地工具或免费公开服务 |
| **隐私安全** | 极高 — 数据不出本机，无需授权第三方 |

### 真正的难点不是抓数据，而是"优先级判断"

1. **信息过载反而更累** — 如果把所有数据都堆出来，用户每天收到一面墙的文字，反而比自己打开 App 还累。Agent 必须做到 **ruthless filtering（无情过滤）**。

2. **优先级判断需要个人上下文** — "这个任务重要吗？"取决于项目处于什么阶段、用户的工作习惯。纯规则难以覆盖，需要结合用户反馈逐步学习。

### 应对策略

- MVP 阶段用 **简单规则**（overdue = 紧急、今日到期 = 高优先级、带 ⚡ = 紧急）
- 记录用户对晨报内容的反馈，逐步训练优先级模型
- 本地工具调用速度极快，无 API 超时风险

---

## 后续扩展

| 版本 | 新增功能 |
|------|----------|
| v2.1 | Browser Use MCP — 自动浏览 Gmail / Slack 网页收集信号 |
| v2.2 | GitHub RSS — 聚合 Issue / PR / Release 通知 |
| v2.3 | 智能学习 — 基于用户行为自动调整优先级权重 |
| v2.4 | 多格式输出 — 支持终端渲染、HTML 预览 |
| v3.0 | 团队版 — 汇总团队成员的当日计划 |

---

## OpenClaw 适配评分

| 维度 | 评分 | 说明 |
|------|------|------|
| **自动化价值** | 10/10 | 每天必须做的事情，完全可以自动化 |
| **数据依赖度** | 2/10 | 零外部 API 依赖，全部本地化 |
| **实现复杂度** | 3/10 | 无需 OAuth / Token 配置，一个 brew install 搞定 |
| **可持续性** | 10/10 | 每天都用，用户粘性极高 |
| **隐私安全** | 10/10 | 数据不出本机 |
| **OpenClaw 适配度** | 10/10 | 完美匹配多 Agent + 定时任务架构 |

**综合评分：45/60** — 最适合作为 OpenClaw 的零门槛入门技能。
