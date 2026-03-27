---
name: daily-briefing
description: >-
  零 API 密钥、零配置的本地晨间简报。当用户说"晨报"、"今日简报"、"morning briefing"、"daily brief"时触发。
  使用 icalBuddy 读取 macOS 原生日历、本地 Markdown 管理待办、RSS 聚合新闻信号、curl 获取天气，
  经过 AI 智能筛选和优先级排序后，生成一份 30 秒内可读完的晨间简报。无需任何 API 密钥或外部服务配置。
user-invocable: true
metadata:
  { "openclaw": { "emoji": "☀️", "primaryEnv": "none", "requires": { "env": [], "anyBins": ["icalBuddy", "curl"], "os": ["darwin"] }, "homepage": "https://github.com/maxazure/skills/tree/main/daily-briefing" } }
---

# Daily Briefing — 零 API 本地晨间简报

## 前置条件

- macOS 系统（使用 icalBuddy 读取原生日历）
- `brew install ical-buddy`（唯一必需的外部工具）
- `~/todos/` 目录存放 Markdown 待办文件（可选）
- `~/daily-briefing-config/feeds.yml` 配置 RSS 订阅源（可选）

无需任何 API 密钥、无需 OAuth 配置、无需外部服务账号。

## 工作流

本技能由 5 个 Agent 协同完成：

1. **Calendar Reader** — 通过 icalBuddy 读取 macOS 原生日历
2. **Task Prioritizer** — 读取 `~/todos/*.md` 本地待办
3. **Signal Collector** — RSS 订阅 + 可选浏览器自动化 + 天气
4. **Executive Summarizer** — 压缩为 30 秒可读的作战板
5. **Delivery Agent** — 保存为本地 Markdown 文件

## Agent 定义

详细的 Agent 提示词定义在 [prompts/calendar-reader.md](prompts/calendar-reader.md)、[prompts/task-prioritizer.md](prompts/task-prioritizer.md)、[prompts/signal-collector.md](prompts/signal-collector.md)、[prompts/executive-summarizer.md](prompts/executive-summarizer.md)、[prompts/delivery-agent.md](prompts/delivery-agent.md)。
