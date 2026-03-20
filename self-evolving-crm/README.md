# Self-Evolving CRM（进化版个人 CRM）

> OpenClaw 技能 | v0.2.0 | SKILL.md 格式 | 一旦跑起来就离不开的关系维护引擎

---

## 概述

Self-Evolving CRM 不是又一个"录联系人"的工具。它解决的核心问题是 **关系维护断层** —— 你认识了很多人，聊过很多事，但总是在关键时刻忘记跟进、漏掉承诺、让关系冷却。

这个技能会自动从你的邮件、日历、会议纪要中提取联系人和互动记录，持续维护一个"活的"联系人数据库，并在每天早上推送你需要跟进的人和事。

**核心理念**：关系不是存出来的，是维护出来的。CRM 不应该是你手动填的表格，而是一个自动运转的关系维护引擎。

### 设计参考

本技能参考了以下产品和开源项目的最佳实践：

| 参考来源 | 借鉴点 |
|---------|--------|
| [PingCRM](https://github.com/sneg55/pingcrm) | 基于 Dunbar 数的关系管理、AI 生活事件检测 |
| [Clay.earth](https://clay.earth/) | 瀑布式联系人充实（多数据源逐级递进） |
| [Dex CRM](https://getdex.com/) | 会前简报、关系升温提醒 |
| [Folk CRM](https://www.folk.app/) | AI 跟进草稿、不活跃对话检测、用户语气学习 |
| [Cloze](https://www.cloze.com/) | 零手动输入、动作短语检测 |
| [Matt Berman's OpenClaw CRM](https://gist.github.com/mberman84/63163d6839053fbf15091238e5ada5c2) | Skip patterns 学习、跨工作流建议 |
| [CRM CLI](https://www.crmcli.sh/) | 自然语言 CRUD、FTS5 全文搜索 |
| [Microsoft Dynamics 365](https://learn.microsoft.com/en-us/dynamics365/sales/relationship-analytics) | 0-100 关系健康评分算法 |
| [Realvolve](https://help.realvolve.com/hc/en-us/articles/360000131263) | 关系衰减公式（考虑关系年龄） |

---

## 目标用户

| 角色 | 痛点 | 价值 |
|------|------|------|
| 销售 | 客户太多记不住，跟进总漏掉 | 自动追踪所有客户互动，到期提醒 |
| 咨询顾问 | 多个项目并行，关系网复杂 | 自动维护关系摘要，不用翻邮件回忆 |
| 自由职业者 | 没有 CRM 系统，靠脑子记 | 零成本启动，邮件驱动，自动运转 |
| 创业者 | 投资人、合作方、客户多线并行 | 每天一条 Telegram 消息掌握全局 |
| 猎头 | 候选人和客户数量庞大 | 自动标记"冷掉"的候选人，不漏跟进 |
| 小型 Agency | 没预算上 Salesforce/HubSpot | 个人版 CRM，AI 驱动，够用且免费 |

---

## 核心能力（v0.2.0）

| # | 能力 | 说明 | 参考来源 |
|---|------|------|---------|
| 1 | **自动采集** | 从 Gmail/日历/会议纪要提取联系人和互动，零手动输入 | Cloze, Salesflare |
| 2 | **联系人充实** | 邮件签名 → 公司网站 → Apollo API，瀑布式自动补全档案 | Clay 瀑布充实, Fire Enrich |
| 3 | **关系健康评分** | 0-100 量化评分，考虑时效性、频率、双向性、关系年龄 | Dynamics 365, Realvolve 衰减公式 |
| 4 | **会前简报** | 开会前自动推送参会者档案、上次互动、建议话题 | Dex, Tavily Meeting Prep |
| 5 | **AI 起草跟进** | 基于关系上下文和用户写作风格，生成个性化消息草稿 | Folk Follow-up Assistant, Fyxer |
| 6 | **待办提取** | 自动识别邮件中的承诺和待办，追踪闭环 | Cloze 动作短语检测 |
| 7 | **智能学习** | 从 approve/reject 决策学习联系人筛选偏好（~50 次后自动模式） | Matt Berman OpenClaw CRM |

---

## 文件结构

```
self-evolving-crm/
├── SKILL.md                         # OpenClaw 技能核心文件（frontmatter + 工作流指令）
├── README.md                        # 本文件（人类可读文档）
└── references/                      # 详细参考文档（按需加载）
    ├── agent-data-collector.md      # 数据采集器规范
    ├── agent-enrichment.md          # 联系人充实规范
    ├── agent-relationship.md        # 关系摘要与健康评分规范
    ├── agent-action-extractor.md    # 待办提取规范
    ├── agent-meeting-prep.md        # 会前简报规范
    ├── agent-draft-writer.md        # AI 起草跟进规范
    └── agent-notifier.md            # 通知推送规范
```

> **格式说明**：本技能遵循 [OpenClaw 官方 Skill 格式](https://docs.openclaw.ai/tools/skills)。`SKILL.md` 是核心文件（YAML frontmatter + Markdown 工作流指令），`references/` 目录下的文档按需加载，不占用 context window。

---

## 7 个 Agent 架构

| Agent | 职责 | 详细规范 |
|-------|------|----------|
| **Data Collector** | 从 Gmail、日历、会议纪要采集原始互动数据 | [`agent-data-collector.md`](references/agent-data-collector.md) |
| **Enrichment** | 邮件签名解析 + 公司网站抓取 + Apollo API 补全档案 | [`agent-enrichment.md`](references/agent-enrichment.md) |
| **Relationship Summarizer** | 关系摘要 + 0-100 健康评分（含衰减公式） | [`agent-relationship.md`](references/agent-relationship.md) |
| **Action Extractor** | 承诺检测、待办提取、闭环追踪 | [`agent-action-extractor.md`](references/agent-action-extractor.md) |
| **Meeting Prep** | 会前 30 分钟推送参会者简报 | [`agent-meeting-prep.md`](references/agent-meeting-prep.md) |
| **Draft Writer** | 基于上下文和用户语气起草跟进消息 | [`agent-draft-writer.md`](references/agent-draft-writer.md) |
| **Notifier** | 每日/每周推送 + Telegram 交互命令 | [`agent-notifier.md`](references/agent-notifier.md) |

---

## 工作流概览

### 三种触发模式

```
              ┌─────────── 每日定时 (cron 8:00) ───────────┐
              │                                              │
              ▼                                              │
  ┌────────────────┐    ┌─────────────┐    ┌──────────────┐ │
  │ Data Collector  │───▶│ Enrichment  │───▶│ Entity       │ │
  │ 数据采集        │    │ 联系人充实   │    │ Resolver     │ │
  └────────────────┘    └─────────────┘    │ 去重合并      │ │
                                           └──────┬───────┘ │
                                                  │          │
                          ┌───────────────────────┼──────┐   │
                          ▼                       ▼      │   │
                  ┌──────────────┐    ┌──────────────┐   │   │
                  │ Relationship │    │ Action       │   │   │
                  │ Summarizer   │    │ Extractor    │   │   │
                  │ 关系摘要+评分 │    │ 待办提取      │   │   │
                  └──────┬───────┘    └──────┬───────┘   │   │
                         │                   │           │   │
                         ▼                   ▼           │   │
                    ┌──────────┐                         │   │
                    │ Notifier │◀────────────────────────┘   │
                    │ 通知推送  │                             │
                    └────┬─────┘                             │
                         │                                   │
                         ▼                                   │
                    Telegram 每日摘要                         │
              ──────────────────────────────────────────────┘

  ┌─────────── 事件触发 ───────────┐    ┌─── 手动触发 ───┐
  │                                │    │                │
  │  会议前 30 分钟                 │    │  "帮我给张三    │
  │         ▼                      │    │   写个跟进"     │
  │  ┌──────────────┐              │    │       ▼        │
  │  │ Meeting Prep │              │    │ ┌────────────┐ │
  │  │ 会前简报      │              │    │ │ Draft      │ │
  │  └──────┬───────┘              │    │ │ Writer     │ │
  │         ▼                      │    │ │ 起草跟进    │ │
  │  Telegram 推送简报              │    │ └────┬───────┘ │
  └────────────────────────────────┘    │      ▼        │
                                        │  草稿供编辑    │
                                        └───────────────┘
```

### 关系健康评分（快速参考）

```
Score = Recency(40%) + Frequency(25%) + Responsiveness(20%) + Depth(15%)

评级:
  80-100 = 🟢 健康        衰减修正:
  50-79  = 🟡 需要关注      新关系 (< 3月): 衰减快 15%/月
  20-49  = 🟠 正在冷却      中期 (3-12月):  衰减中 10%/月
  0-19   = 🔴 即将断联      老关系 (> 1年): 衰减慢 5%/月
```

> 完整算法说明见 [`SKILL.md`](SKILL.md) 和 [`agent-relationship.md`](references/agent-relationship.md)。

### Telegram 交互命令

| 命令 | 功能 |
|------|------|
| `/detail <联系人>` | 显示完整联系人档案 |
| `/done <action_id>` | 标记待办已完成 |
| `/snooze <联系人> <天数>` | 延后跟进提醒 |
| `/draft <联系人>` | 触发起草跟进消息 |
| `/merge_yes` / `/merge_no` | 确认/拒绝联系人合并 |
| `/overdue` | 查看所有逾期待办 |
| `/today` | 查看今日所有跟进 |
| `/health` | 查看所有联系人健康评分 |
| `/stats` | 查看 CRM 统计数据 |

---

## 适配评分

| 维度 | 评分 | 说明 |
|------|------|------|
| 自动化价值 | 9/10 | 从邮件自动提取联系人和待办，几乎零手动操作 |
| 数据依赖度 | 7/10 | 依赖 Gmail API，需要用户授权 |
| 实现复杂度 | 7/10 | Gmail 接入、联系人去重、关系记忆是主要挑战 |
| 可持续性 | 10/10 | 一旦跑起来，越用数据越丰富，粘性极高 |
| 商业化潜力 | 9/10 | 从个人版到团队版路径清晰 |
| **OpenClaw 适配度** | **10/10** | 完美利用定时任务、持久记忆、多平台通知 |

---

## 快速开始

### 1. 安装

```bash
clawhub install self-evolving-crm
```

### 2. 配置环境变量

**必需：**

| 变量 | 用途 | 获取方式 |
|------|------|---------|
| `GMAIL_OAUTH_CREDENTIALS` | Gmail 读取权限 | [Google Cloud Console](https://console.cloud.google.com/) |
| `GOOGLE_CALENDAR_CREDENTIALS` | 日历读取权限 | [Google Cloud Console](https://console.cloud.google.com/) |
| `TELEGRAM_BOT_TOKEN` | 推送通知 | [@BotFather](https://t.me/BotFather) |
| `TELEGRAM_CHAT_ID` | 推送目标 | Telegram |

**可选：**

| 变量 | 用途 | 说明 |
|------|------|------|
| `APOLLO_API_KEY` | 联系人充实 | 免费 10,000 次/月 |
| `BRAVE_SEARCH_API_KEY` | 公司信息搜索 | 免费 2,000 次/月 |
| `NOTION_API_KEY` | 同步到 Notion | 可选存储后端 |

```bash
export GMAIL_OAUTH_CREDENTIALS="./credentials/gmail-oauth.json"
export GOOGLE_CALENDAR_CREDENTIALS="./credentials/calendar-oauth.json"
export TELEGRAM_BOT_TOKEN="your_bot_token"
export TELEGRAM_CHAT_ID="your_chat_id"
```

### 3. 首次运行

```bash
openclaw run self-evolving-crm
```

### 4. 启用定时任务

```bash
# 每日 CRM 扫描 + 推送（每天 8:00）
openclaw cron add --name "crm-daily" --cron "0 8 * * *" \
  --tz "Pacific/Auckland" --session isolated \
  --message "运行 Self-Evolving CRM 每日扫描" --wake now

# 会前简报（每小时检查接下来 60 分钟内的会议）
openclaw cron add --name "crm-meeting-prep" --cron "0 * * * *" \
  --tz "Pacific/Auckland" --session isolated \
  --message "检查接下来 60 分钟内的会议，生成简报" --wake now

# 每周关系健康报告（每周一 9:00）
openclaw cron add --name "crm-weekly" --cron "0 9 * * 1" \
  --tz "Pacific/Auckland" --session isolated \
  --message "生成本周关系健康报告" --wake now
```

### 5. 验证

首次运行后你应该看到：
- Telegram 收到 CRM 日报消息
- `~/.openclaw/workspace/self-evolving-crm/` 下生成状态文件
- MEMORY.md 中出现联系人数据

---

## 数据存储

| 位置 | 内容 | 说明 |
|------|------|------|
| `MEMORY.md` | 联系人档案、跳过规则、写作风格、用户偏好 | OpenClaw 持久记忆，跨会话保持 |
| `memory/YYYY-MM-DD.md` | 每日互动记录、新增联系人、状态变化 | 日志文件 |
| `~/.openclaw/workspace/self-evolving-crm/last_scan.json` | 上次扫描时间戳 | 增量扫描依据 |
| `~/.openclaw/workspace/self-evolving-crm/processed_ids.json` | 已处理邮件 ID | 避免重复处理 |
| `~/.openclaw/workspace/self-evolving-crm/decisions.json` | 用户 approve/reject 历史 | 智能学习训练数据 |

---

## 安全与护栏

- **只读邮件**：永远不发送邮件，只读取。起草的跟进消息必须由用户确认后手动发送
- **隐私优先**：所有数据存储在本地，不上传到任何外部服务
- **合并确认**：低置信度的联系人合并必须用户确认，不自动执行
- **健康评分透明**：每个评分都附带计算依据，不是黑箱
- **数据量限制**：processed_ids 最多保留 10,000 条（FIFO 淘汰）
