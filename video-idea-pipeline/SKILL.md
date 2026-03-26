---
name: video-idea-pipeline
description: >-
  把模糊创意自动变成可执行内容 Brief。当用户提到"视频选题"、"内容创意"、"video brief"、"创作灵感"、"帮我做个视频策划"时触发。
  接收用户的一句模糊内容想法，通过多 Agent 协作自动完成趋势研究、受众分析、竞品调研、角度定位，最终输出一份完整的、可直接用于脚本创作的视频内容 Brief。
user-invocable: true
metadata:
  { "openclaw": { "emoji": "🎬", "primaryEnv": "BRAVE_SEARCH_API_KEY", "requires": { "env": ["BRAVE_SEARCH_API_KEY"], "anyBins": ["node"], "os": ["darwin", "linux"] }, "homepage": "https://github.com/maxazure/skills/tree/main/video-idea-pipeline" } }
---

# Video Idea Pipeline — 视频创意全自动漏斗

## 工作流

本工作流通过 5 个专业 Agent 协作，将用户的模糊创意自动转化为完整的视频内容 Brief：

1. **idea_expander** — 创意扩展器：把模糊想法扩展成多个搜索方向和关键词
2. **trend_researcher** — 趋势研究员：从多平台搜索热点、竞品内容、讨论趋势
3. **audience_mapper** — 受众定位器：识别目标人群画像和传播机会
4. **positioning_strategist** — 定位策略师：确定内容差异化角度、标题方向、风险评估
5. **brief_writer** — Brief 撰写器：汇总所有信息，输出完整可执行的内容 Brief

## Agent 定义

详细的 Agent 提示词定义在 prompts/ 目录中。

## 依赖说明

本工作流依赖 Brave Search API（免费 2000 次/月）。YouTube、Reddit、X/Twitter 数据可通过 Brave Search 的网页搜索结果获取，无需单独申请 API Key。
