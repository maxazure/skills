---
name: daily-briefing
description: >-
  把用户每天最重要的信息压缩成一条可执行晨报。当用户说"晨报"、"今日简报"、"morning briefing"、"daily brief"时触发。
  每天早上自动聚合日历、待办、邮件等信息源，经过 AI 智能筛选和优先级排序后，
  生成一份 30 秒内可读完的晨间简报。
user-invocable: true
metadata:
  { "openclaw": { "emoji": "☀️", "primaryEnv": "TELEGRAM_BOT_TOKEN", "requires": { "env": ["TELEGRAM_BOT_TOKEN", "TELEGRAM_CHAT_ID"], "anyBins": ["node"], "os": ["darwin", "linux"] }, "homepage": "https://github.com/maxazure/skills/tree/main/daily-briefing" } }
---

# Daily Briefing — 全能晨间简报

## 工作流

[Describe the 5-agent pipeline in Chinese. Reference the prompts/ directory for detailed agent definitions.]

## Agent 定义

详细的 Agent 提示词定义在 [prompts/calendar-reader.md](prompts/calendar-reader.md)、[prompts/task-prioritizer.md](prompts/task-prioritizer.md)、[prompts/signal-collector.md](prompts/signal-collector.md)、[prompts/executive-summarizer.md](prompts/executive-summarizer.md)、[prompts/delivery-agent.md](prompts/delivery-agent.md)。
