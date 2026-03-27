# Video Idea Pipeline（视频创意全自动漏斗）

> 零 API 密钥 — 把模糊创意自动变成可执行内容 Brief

## 概述

Video Idea Pipeline 是一个 OpenClaw 自动化技能，能将一句模糊的内容想法（如"我想做一个关于 AI 编程的视频"）自动转化为一份**完整、可执行的视频内容 Brief**。

整个流程由 5 个 AI Agent 协作完成，通过 **Browser Use MCP** 浏览器自动化技术直接访问各大平台获取真实数据——自动搜索热点趋势、分析竞品内容、锁定目标受众、确定差异化角度，最终输出一份拿到就能开写脚本的 Brief 文档。

**核心承诺**：从"我想做这个方向"到"可以直接开写脚本"，时间从半天降到 10 分钟以内。**零 API 密钥，零成本。**

---

## 零 API 密钥方案

传统方案需要申请 5+ 个 API 密钥（Brave Search、YouTube Data API、Reddit API、Twitter/X API...），月成本 $100+。

本技能通过 **Browser Use MCP** 实现完全免费的数据采集：

| 传统 API 方案 | 本技能（Browser Use） |
|--------------|---------------------|
| Brave Search API（$0-99/月） | Browser Use 浏览 Google/DuckDuckGo |
| YouTube Data API（有配额限制） | Browser Use 浏览 YouTube 搜索页面 |
| Reddit API（需申请 OAuth） | Browser Use 浏览 Reddit + RSS feeds |
| Twitter/X API（$100/月） | Browser Use 浏览 X.com 搜索 |
| Google Trends（pytrends 不稳定） | Browser Use 浏览 trends.google.com |
| Notion API（输出渠道） | 本地 Markdown 文件 |
| Telegram Bot API（输出渠道） | 本地 Markdown 文件 |

**Browser Use** 是一个开源 AI 浏览器自动化框架（84K+ GitHub stars），可控制真实 Chromium 浏览器。它能导航到任何网页、读取内容、提取结构化数据，就像人类手动浏览一样——但完全自动化。

---

## 目标用户

- **YouTuber / B站UP主**：需要持续产出高质量选题
- **自媒体创作者**：公众号、小红书、抖音等内容创作者
- **内容团队**：需要标准化选题流程的内容运营团队
- **知识付费从业者**：需要快速验证内容方向的可行性
- **MCN 机构**：批量生成选题 Brief 分发给签约达人

---

## 核心价值

| 传统方式 | 使用 Video Idea Pipeline |
|----------|------------------------|
| 手动刷 X/Reddit/YouTube 找灵感（2-3 小时） | 自动浏览多平台数据采集（5-10 分钟） |
| 凭感觉判断选题好不好（主观） | 数据驱动的趋势分析和竞品评估（客观） |
| 反复修改选题方向（半天-一天） | 一次性输出 3 个差异化标题方向（5 分钟） |
| Brief 格式不统一，遗漏关键信息 | 标准化 Brief 模板，字段完整 |
| 需要申请多个 API 密钥和付费订阅 | 零 API 密钥，零成本 |

---

## 工作流概述

### 5 个 Agent 协作流水线

```
用户输入模糊想法
       │
       ▼
┌─────────────────┐
│  Agent 1         │
│  Idea Expander   │  把模糊想法扩展成多个搜索方向和关键词
│  （创意扩展器）    │  输出：5-10 个搜索查询 + 关键词 + 角度建议
└───────┬─────────┘
        │
        ▼
┌─────────────────┐
│  Agent 2         │  通过 Browser Use MCP 浏览：
│  Trend Researcher│  - Google 搜索 → 综合搜索结果
│  （趋势研究员）    │  - YouTube → 竞品视频和数据
│                  │  - Reddit → 社区讨论和热帖
│                  │  - X/Twitter → 实时热点话题
│                  │  - Google Trends → 趋势走势
│                  │  输出：趋势数据 + 竞品分析 + 讨论主题 + 时效性评估
└───────┬─────────┘
        │
        ▼
┌─────────────────┐
│  Agent 3         │
│  Audience Mapper │  识别目标人群画像和传播机会
│  （受众定位器）    │  输出：受众画像 + 痛点 + 共鸣角度 + 传播潜力
└───────┬─────────┘
        │
        ▼
┌─────────────────┐
│  Agent 4         │
│  Positioning     │  确定内容差异化角度、标题方向、风险评估
│  Strategist      │
│  （定位策略师）    │  输出：推荐角度 + 3 个标题 + 风险评估 + 竞争强度
└───────┬─────────┘
        │
        ▼
┌─────────────────┐
│  Agent 5         │
│  Brief Writer    │  输出完整可执行的内容 Brief
│  （Brief 撰写器） │  输出：完整 video_brief YAML → Markdown 文件
└───────┬─────────┘
        │
        ▼
  ~/video-briefs/{date}-{slug}.md
```

---

## 配置说明

### 安装 Browser Use MCP

只需一条命令：

```bash
claude mcp add browser-use -- uvx --from 'browser-use[cli]' browser-use --mcp
```

**前置条件**：
- Python 3.11+（用于 uvx）
- Chromium 浏览器（Browser Use 会自动下载）

**无需任何 API 密钥或环境变量配置。**

### 验证安装

安装完成后，在 Claude Code 中运行 `/mcp` 查看 browser-use 是否已连接。

---

## MVP 版本说明

MVP 版本的核心流程：

1. **输入**：用户提供一句模糊想法（例如："我想做一个关于用 AI 写代码的视频"）
2. **自动浏览**：系统通过 Browser Use MCP 自动浏览 Google、YouTube、Reddit、X/Twitter、Google Trends 等平台
3. **输出**：一页完整的内容 Brief（Markdown 格式，保存到 `~/video-briefs/` 目录）

### 最小可用版本要求

- 支持中文和英文输入
- 默认目标平台为 YouTube（可切换为 B站、小红书等）
- 搜索范围：近 7-30 天的数据（通过浏览器直接获取，数据始终最新）
- 输出格式：Markdown 文件（包含完整 YAML 结构）

---

## 输出模板

```yaml
video_brief:
  # 原始输入
  raw_idea: "用户的原始想法"

  # 精炼后的角度
  refined_angle: "经过研究后确定的具体切入角度"

  # 目标受众
  target_audience:
    primary: "核心目标人群描述"
    demographics: "年龄、职业、兴趣标签"
    pain_points:
      - "痛点 1"
      - "痛点 2"
    content_consumption_habits: "他们通常在哪里看什么类型的内容"

  # 为什么是现在
  why_now:
    trend_signal: "当前趋势信号"
    timeliness: "时效性评估（1-10）"
    data_sources:
      - platform: "X/Twitter"
        signal: "相关讨论量/话题热度"
      - platform: "YouTube"
        signal: "近期相关视频的表现数据"
      - platform: "Google Trends"
        signal: "搜索趋势变化"

  # 竞品分析
  competitors:
    - title: "竞品视频/内容标题"
      platform: "平台"
      engagement: "互动数据（观看量/点赞/评论）"
      angle: "他们的切入角度"
      gap: "我们可以补充的空白点"

  # 标题候选（3 个）
  hooks:
    primary: "主要 hook —— 用户为什么要点开"
    emotional_trigger: "情感触发点"

  titles:
    - "标题候选 1（最推荐）"
    - "标题候选 2（备选）"
    - "标题候选 3（实验性）"

  # 内容大纲（5 段式结构）
  outline:
    - section: "Hook 开场（0:00-0:30）"
      purpose: "hook + 建立期待"
      key_points:
        - "关键内容点"
    - section: "背景铺垫（0:30-2:00）"
      purpose: "让观众产生共鸣，建立问题意识"
      key_points:
        - "关键内容点"
    - section: "核心论点 Part 1（2:00-5:00）"
      purpose: "提供核心价值、第一层深度"
      key_points:
        - "关键内容点"
        - "证据/案例来源"
    - section: "核心论点 Part 2（5:00-8:00）"
      purpose: "进一步展开、对比或实操演示"
      key_points:
        - "关键内容点"
        - "证据/案例来源"
    - section: "总结 + CTA（8:00-10:00）"
      purpose: "总结要点 + 引导行动"
      key_points:
        - "关键内容点"

  # 行动号召
  call_to_action:
    primary: "主要 CTA（如：订阅、关注）"
    secondary: "次要 CTA（如：评论区讨论、下载资源）"

  # 元数据
  metadata:
    competition_intensity: "竞争强度评分（1-10）"
    virality_potential: "传播潜力评分（1-10）"
    estimated_production_time: "预计制作时间"
    recommended_length: "建议视频时长"
    tags:
      - "标签1"
      - "标签2"
```

---

## 难点与风险

### 技术风险

1. **浏览器自动化速度**
   - Browser Use 操控真实浏览器，比 API 调用更慢（每个平台约 30-60 秒）
   - 总体研究时间约 5-10 分钟（API 方案约 2 分钟）
   - 优势：数据始终最新、最真实，零成本

2. **平台反爬机制**
   - 部分平台（如 X/Twitter）可能有反爬策略
   - 解决方案：Browser Use 使用真实浏览器行为，不易被检测；如某平台失败，继续用其他平台数据
   - Reddit RSS feeds 作为备用数据源，稳定性极高

3. **热点数据噪音大**
   - 搜索结果中大量低质量内容，需要有效的过滤和排序策略
   - 不同平台的 engagement 指标不可直接对比（YouTube 观看量 vs X 转发量）

4. **多语言/多平台适配**
   - 中文内容生态（B站、小红书、微博）与英文生态（YouTube、Reddit、X）差异巨大
   - 需要针对不同平台调整搜索策略和数据解读方式

### 内容风险

5. **用户定位模糊导致 Brief 发散**
   - 如果用户没有明确的频道定位/内容方向，Brief 可能过于泛化
   - 解决方案：首次使用时引导用户填写 content_pillars（内容支柱）

6. **数据时效性**
   - 热点窗口期短，Brief 生成后需要快速执行
   - 优势：Browser Use 直接浏览真实网页，数据始终是最新的（比缓存型 API 更及时）

---

## 后续扩展

- **封面生成**：基于 Brief 自动生成视频封面（接入 Gemini Image Gen）
- **脚本写作**：基于 Brief 自动生成完整视频脚本初稿
- **SEO 优化**：自动生成视频描述、标签、关键词优化建议
- **竞品深度分析**：对标竞品频道的内容策略、更新频率、增长趋势
- **表现追踪**：视频发布后自动追踪数据，反馈到 memory 优化后续选题
- **批量生成**：一次输入多个想法，批量生成 Brief 并排序推荐
- **团队协作**：Brief 审批流程、多人评论、任务分配
- **多平台适配**：同一个 Brief 自动适配不同平台的内容格式和规则

---

## 适配评分表

| 维度 | 评分 | 说明 |
|------|------|------|
| **自动化价值** | 9/10 | 完整流水线，从输入到输出全自动，大幅节省选题时间 |
| **数据依赖度** | 9/10 | 通过 Browser Use 直接浏览网页，不依赖任何付费 API |
| **实现复杂度** | 5/10 | 5 个 Agent 的编排逻辑清晰，Browser Use MCP 简化了数据采集 |
| **可持续性** | 10/10 | 浏览器自动化不受 API 定价变化影响，长期成本为零 |
| **商业化潜力** | 10/10 | 可按次收费、按月订阅，直接为创作者节省时间和提升质量 |
| **OpenClaw 适配度** | 10/10 | 天然适合 Agent 编排，零配置门槛吸引更多用户 |

**综合适配评分：10/10** — 零 API 密钥的设计大幅降低了使用门槛，商业化路径最清晰的技能之一。
