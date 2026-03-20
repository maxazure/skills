# Daily Briefing — 全能晨间简报

> 把用户每天最重要的信息压缩成一条可执行晨报。

---

## 概述

Daily Briefing 是 OpenClaw 平台上的高优先级个人助理技能。它在每天早上自动聚合你的日历、待办事项、邮件等多个信息源，经过 AI 智能筛选和优先级排序后，生成一份 **30 秒内可读完** 的晨间简报，推送到你的 Telegram / 邮箱（Slack 计划中）。

**核心理念**：你不需要每天早上打开 5 个 App 才能知道今天该干什么。一条消息，全部搞定。

---

## 目标用户

- **独立开发者**：每天在代码、客户、产品之间切换，需要快速理清优先级
- **创业者 / Solo Founder**：信息源多且杂，容易遗漏重要事项
- **高信息密度工作者**：会议多、邮件多、待办多，需要一个"每日作战板"

---

## 核心价值

| 痛点 | Daily Briefing 的解决方式 |
|------|--------------------------|
| 每天早上要打开日历、邮箱、Todoist、Slack... | 一条消息汇总所有 |
| 不知道今天最重要的事是什么 | AI 自动排出 Top 3 优先级 |
| 会议冲突没注意到 | 自动检测并预警 |
| 过期任务越积越多 | 主动提醒 overdue 事项 |
| 客户邮件忘了回 | 抓取星标/紧急邮件摘要 |

---

## 工作流概述

本技能由 5 个 Agent 协同完成，按流水线顺序执行：

```
┌─────────────┐   ┌──────────────┐   ┌────────────────┐
│ 1. Calendar  │   │ 2. Task      │   │ 3. Signal      │
│    Reader    │   │    Prioritizer│   │    Collector    │
│ 读取今日会议  │   │ 整理待办优先级 │   │ 收集重要通知    │
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
              │ 推送到 Telegram/邮箱   │
              └───────────────────────┘
```

| Agent | 职责 | 输入 | 输出 |
|-------|------|------|------|
| Calendar Reader | 读取今日会议、识别冲突、找出空档 | Google Calendar API | 会议列表 + 冲突警告 + 空闲时段 |
| Task Prioritizer | 读取待办并智能排序 | Todoist / Notion / 本地 Markdown | 按优先级排序的任务列表（Top 3-5） |
| Signal Collector | 收集重要通知和未读重点 | Gmail 星标/未读、CRM 更新 | 重要信号列表 |
| Executive Summarizer | 压缩成可执行晨报 | 前三个 Agent 的输出 | daily_brief YAML 结构 |
| Delivery Agent | 格式化并推送 | 晨报内容 | Telegram / Email / Markdown 文件 |

---

## MVP 版本说明

**第一版只接入最核心的三个数据源**，保证快速上线和稳定运行：

1. **Google Calendar** — 今日会议和明天上午的会议
2. **Todoist / Notion / 本地待办** — 今日到期和 overdue 的任务（三选一即可）
3. **Gmail 星标或未读重点** — 过去 24 小时的星标邮件和重要未读

> MVP 不做：CRM 联系记录、社媒提醒、Slack 未读、天气/交通。这些放到后续版本。

---

## 输出示例

```yaml
daily_brief:
  date: "2026-03-20"
  today_in_one_sentence: "上午有两个连续会议，下午是深度工作窗口，BestAI 客户报价今天必须发出。"

  top_priorities:
    - "发出 BestAI 客户报价方案（截止 18:00）"
    - "Review PR #42 — 阻塞了下游部署"
    - "回复 Gmail 星标邮件：供应商合同确认"

  meetings:
    - time: "09:30-10:00"
      title: "周三站会"
      attendees: ["团队全员"]
      notes: "准备本周进度汇报"
    - time: "10:00-11:00"
      title: "客户需求对齐"
      attendees: ["李总", "产品组"]
      notes: "⚠️ 与站会背靠背，无缓冲时间"

  conflict_alerts:
    - "09:30-11:00 连续两个会议，建议站会提前 5 分钟结束"

  free_slots:
    - "11:00-12:00（1h 空档）"
    - "14:00-17:30（3.5h 深度工作窗口）"

  urgent_followups:
    - source: "Gmail"
      summary: "供应商合同需要确认签字 — 发件人：张经理"
      urgency: "high"
    - source: "Todoist"
      summary: "服务器 SSL 证书下周到期，需要续期"
      urgency: "medium"

  risk_alerts:
    - "BestAI 报价方案今天截止，目前还没有开始写"
    - "本周已有 3 个 overdue 任务未处理"

  suggested_focus: "上午处理会议和邮件回复，下午 14:00 后进入深度工作模式，专注完成 BestAI 报价方案"
```

---

## 配置说明

### 必需的 API / Token

| 服务 | 用途 | 获取方式 |
|------|------|----------|
| **Google Calendar API** | 读取日历事件 | [Google Cloud Console](https://console.cloud.google.com/) → 启用 Calendar API → 创建 OAuth 凭证 |
| **Gmail API** | 读取星标/未读邮件 | 同上，启用 Gmail API（通常与 Calendar 共用一个 OAuth 凭证） |
| **Todoist API Token** | 读取待办事项 | [Todoist 设置 → 集成](https://todoist.com/app/settings/integrations) → 获取 API Token |
| **Notion API**（可选，与 Todoist 二选一） | 读取 Notion 数据库中的待办 | [Notion Integrations](https://www.notion.so/my-integrations) → 创建 Integration |
| **Telegram Bot Token** | 推送晨报 | [@BotFather](https://t.me/BotFather) → /newbot → 获取 Token |

### 可选配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `schedule` | 晨报推送时间 | `09:00` |
| `timezone` | 时区 | `Pacific/Auckland` |
| `max_priorities` | 最多展示几个 Top Priority | `3` |
| `email_lookback_hours` | 邮件回溯多少小时 | `24` |
| `delivery_channels` | 推送渠道列表 | `["telegram"]` |

---

## 难点与风险

### 真正的难点不是抓数据，而是"优先级判断"

技术层面，接入 Google Calendar、Gmail、Todoist 的 API 都不难。真正的挑战在于：

1. **信息过载反而更累** — 如果把所有数据都堆出来，用户每天收到一面墙的文字，反而比自己打开 App 还累。Agent 必须做到 **ruthless filtering（无情过滤）**。

2. **优先级判断需要个人上下文** — "这封邮件重要吗？"取决于发件人是谁、项目处于什么阶段、用户的工作习惯。纯规则难以覆盖，需要结合用户反馈逐步学习。

3. **时效性** — 晨报必须在用户起床后 30 秒内可读，如果 API 调用太慢导致推送延迟，体验会大打折扣。

### 应对策略

- MVP 阶段用 **简单规则**（星标 = 重要、overdue = 紧急、今日到期 = 高优先级）
- 记录用户对晨报内容的反馈（点击了哪些、忽略了哪些），逐步训练优先级模型
- API 调用并行化，设置超时兜底

---

## 后续扩展

| 版本 | 新增功能 |
|------|----------|
| v1.1 | CRM 联系记录 — 提醒今天需要跟进的客户 |
| v1.2 | Slack 未读 — 汇总重要频道的未读消息 |
| v1.3 | 社媒提醒 — Twitter/X 关注者动态、GitHub 通知 |
| v1.4 | 天气 + 通勤 — 出门提醒、交通状况 |
| v2.0 | 智能学习 — 基于用户行为自动调整优先级权重 |
| v2.1 | 多人版 — 团队晨报，汇总团队成员的当日计划 |

---

## OpenClaw 适配评分

| 维度 | 评分 | 说明 |
|------|------|------|
| **自动化价值** | 10/10 | 每天必须做的事情，完全可以自动化，节省时间最直观 |
| **数据依赖度** | 6/10 | 依赖 Google、Todoist 等外部 API，但都有成熟的接口 |
| **实现复杂度** | 5/10 | 单个 API 对接都不难，难点在优先级排序逻辑 |
| **可持续性** | 10/10 | 每天都用，用户粘性极高，是天然的高频入口 |
| **商业化潜力** | 8/10 | 可作为付费 AI 助手的核心功能，也可独立售卖 |
| **OpenClaw 适配度** | 10/10 | 完美匹配 OpenClaw 的多 Agent + 定时任务 + 消息推送架构 |

**综合评分：49/60** — 最适合作为 OpenClaw 的第一个正式技能，也是整个系统的入口工作流。
