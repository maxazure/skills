# Video Idea Pipeline（视频创意全自动漏斗）

> 把模糊创意自动变成可执行内容 Brief

## 概述

Video Idea Pipeline 是一个 OpenClaw 自动化技能，能将一句模糊的内容想法（如"我想做一个关于 AI 编程的视频"）自动转化为一份**完整、可执行的视频内容 Brief**。

整个流程由 5 个 AI Agent 协作完成，自动搜索热点趋势、分析竞品内容、锁定目标受众、确定差异化角度，最终输出一份拿到就能开写脚本的 Brief 文档。

**核心承诺**：从"我想做这个方向"到"可以直接开写脚本"，时间从半天降到 10 分钟以内。

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
| 手动刷 X/Reddit/YouTube 找灵感（2-3 小时） | 自动多平台数据采集（2 分钟） |
| 凭感觉判断选题好不好（主观） | 数据驱动的趋势分析和竞品评估（客观） |
| 反复修改选题方向（半天-一天） | 一次性输出 3 个差异化标题方向（5 分钟） |
| Brief 格式不统一，遗漏关键信息 | 标准化 Brief 模板，字段完整 |
| 选题会开一小时，产出 3 个选题 | 10 分钟产出 1 个完整可执行 Brief |

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
│  Agent 2         │
│  Trend Researcher│  从多平台搜索热点、竞品内容、讨论趋势
│  （趋势研究员）    │  输出：趋势数据 + 竞品分析 + 讨论主题 + 时效性评估
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
│  （Brief 撰写器） │  输出：完整 video_brief YAML
└───────┬─────────┘
        │
        ▼
  完整 Brief 文档
```

---

## MVP 版本说明

MVP 版本的核心流程：

1. **输入**：用户提供一句模糊想法（例如："我想做一个关于用 AI 写代码的视频"）
2. **自动搜索**：系统自动搜索 X/Twitter、Reddit、YouTube、Google Trends 等平台
3. **输出**：一页完整的内容 Brief（Markdown 或 YAML 格式）

### 最小可用版本要求

- 支持中文和英文输入
- 默认目标平台为 YouTube（可切换为 B站、小红书等）
- 搜索范围：近 7-30 天的数据
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

## 配置说明

### 必需的 API / Token

| API | 用途 | 获取方式 | 费用 |
|-----|------|---------|------|
| **Brave Search API** | 通用网页搜索、新闻检索 | https://brave.com/search/api/ | 免费额度 2000次/月 |
| **YouTube Data API v3** | 搜索竞品视频、获取数据 | Google Cloud Console | 免费额度 10,000 单位/天 |
| **Reddit API** | 搜索相关讨论和热门帖子 | https://www.reddit.com/prefs/apps | 免费（100 QPS） |
| **Twitter/X API** | 搜索热点话题和讨论 | https://developer.x.com/ | Basic $100/月 或使用 scraper |
| **Google Trends** | 搜索趋势分析 | 无需 API（通过 pytrends 或 scraping） | 免费 |

### 可选的 API

| API | 用途 | 说明 |
|-----|------|------|
| Notion API | 将 Brief 写入 Notion | 需要 Integration Token |
| Telegram Bot API | 推送 Brief 到 Telegram | 需要 Bot Token |
| Google Sheets API | 将 Brief 追加到表格 | 用于团队协作 |

### 环境变量配置

```bash
# 必需
export BRAVE_SEARCH_API_KEY="your-key"
export YOUTUBE_API_KEY="your-key"
export REDDIT_CLIENT_ID="your-id"
export REDDIT_CLIENT_SECRET="your-secret"

# X/Twitter（二选一）
export TWITTER_BEARER_TOKEN="your-token"     # 官方 API
# 或使用 scraper 方案，无需 token

# 可选
export NOTION_API_KEY="your-key"
export TELEGRAM_BOT_TOKEN="your-token"
```

---

## 难点与风险

### 技术风险

1. **平台 API 限制**
   - X/Twitter API Basic 版 $100/月，成本较高
   - 替代方案：使用 Nitter 或其他开源 scraper，但稳定性较差
   - YouTube API 每日配额有限，批量使用时需注意限流

2. **热点数据噪音大**
   - 搜索结果中大量低质量内容，需要有效的过滤和排序策略
   - 不同平台的 engagement 指标不可直接对比（YouTube 观看量 vs X 转发量）

3. **多语言/多平台适配**
   - 中文内容生态（B站、小红书、微博）与英文生态（YouTube、Reddit、X）差异巨大
   - 需要针对不同平台调整搜索策略和数据解读方式

### 内容风险

4. **用户定位模糊导致 Brief 发散**
   - 如果用户没有明确的频道定位/内容方向，Brief 可能过于泛化
   - 解决方案：首次使用时引导用户填写 content_pillars（内容支柱）

5. **数据时效性**
   - 热点窗口期短，Brief 生成后需要快速执行
   - 建议在 Brief 中标注时效性评分，提示用户优先级

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
| **数据依赖度** | 7/10 | 依赖多个平台 API，但核心逻辑不依赖单一数据源 |
| **实现复杂度** | 6/10 | 5 个 Agent 的编排逻辑清晰，难点在数据采集和去噪 |
| **可持续性** | 9/10 | 内容创作是持续需求，选题永远是核心痛点 |
| **商业化潜力** | 10/10 | 可按次收费、按月订阅，直接为创作者节省时间和提升质量 |
| **OpenClaw 适配度** | 10/10 | 天然适合 Agent 编排，可接入多平台消息推送和定时触发 |

**综合适配评分：10/10** — 演示价值最强，商业化路径最清晰的技能之一。
