---
name: video-idea-pipeline
description: >-
  把模糊创意自动变成可执行内容 Brief（零 API 密钥版）。当用户提到"视频选题"、"内容创意"、"video brief"、"创作灵感"、"帮我做个视频策划"时触发。
  接收用户的一句模糊内容想法，通过多 Agent 协作自动完成趋势研究、受众分析、竞品调研、角度定位，最终输出一份完整的、可直接用于脚本创作的视频内容 Brief。
  所有研究数据通过 Browser Use MCP 浏览器自动化获取，无需任何 API 密钥。
user-invocable: true
metadata:
  { "openclaw": { "emoji": "🎬", "primaryEnv": "none", "requires": { "mcp": ["browser-use"], "anyBins": ["uvx"], "os": ["darwin", "linux"] }, "homepage": "https://github.com/maxazure/skills/tree/main/video-idea-pipeline" } }
---

# Video Idea Pipeline — 视频创意全自动漏斗（零 API 密钥版）

## 前置要求

本技能需要 Browser Use MCP 服务器。安装方式：

```bash
claude mcp add browser-use -- uvx --from 'browser-use[cli]' browser-use --mcp
```

Browser Use 是一个开源 AI 浏览器自动化框架（84K+ GitHub stars），可控制真实 Chromium 浏览器完成所有研究任务。无需任何 API 密钥。

## 工作流

本工作流通过 5 个专业 Agent 协作，将用户的模糊创意自动转化为完整的视频内容 Brief：

1. **idea_expander** — 创意扩展器：把模糊想法扩展成多个搜索方向和关键词
2. **trend_researcher** — 趋势研究员：通过 Browser Use 浏览多平台，搜索热点、竞品内容、讨论趋势
3. **audience_mapper** — 受众定位器：识别目标人群画像和传播机会
4. **positioning_strategist** — 定位策略师：确定内容差异化角度、标题方向、风险评估
5. **brief_writer** — Brief 撰写器：汇总所有信息，输出完整可执行的内容 Brief

## 数据来源

所有数据通过 Browser Use MCP 直接浏览真实网页获取：

| 平台 | 访问方式 | 获取数据 |
|------|---------|---------|
| Google | 浏览 google.com 搜索 | 综合搜索结果、新闻 |
| YouTube | 浏览 youtube.com 搜索 | 竞品视频、播放量、互动数据 |
| Reddit | 浏览 reddit.com 搜索 + RSS | 社区讨论、热帖、评论 |
| X/Twitter | 浏览 x.com 搜索 | 热点话题、讨论趋势 |
| Google Trends | 浏览 trends.google.com | 搜索趋势、热度走势 |

## Agent 定义

详细的 Agent 提示词定义在 prompts/ 目录中。
