---
name: self-evolving-crm
description: >-
  个人 CRM 自动化技能。从 Gmail、日历、会议纪要中自动提取联系人和互动记录，
  维护关系摘要和健康评分，推送跟进提醒和会前简报，起草跟进消息。
  当用户提到"联系人管理"、"跟进提醒"、"关系维护"、"CRM"、"会前准备"时触发。
version: 0.2.0
user-invocable: true
metadata: {"openclaw":{"emoji":"🤝","primaryEnv":"GMAIL_OAUTH_CREDENTIALS","requires":{"env":["GMAIL_OAUTH_CREDENTIALS","GOOGLE_CALENDAR_CREDENTIALS","TELEGRAM_BOT_TOKEN","TELEGRAM_CHAT_ID"],"anyBins":["node","python3"],"os":["darwin","linux"]},"homepage":"https://github.com/maxazure/skills/tree/main/self-evolving-crm"}}
---

# Self-Evolving CRM — 进化版个人 CRM

> 不是又一个"录联系人"的工具。解决的核心问题是 **关系维护断层**。

## 何时使用

- 用户想管理联系人关系、查询联系人信息
- 需要跟进提醒（"谁该联系了？"）
- 会议前需要准备参会者简报
- 想起草跟进邮件/消息
- 想了解关系健康状况（"哪些关系在冷却？"）

## 核心能力

1. **自动采集** — 从 Gmail/日历/会议纪要提取联系人和互动，零手动输入
2. **联系人充实** — 自动从邮件签名、公司网站补全职位/公司/LinkedIn
3. **关系健康评分** — 0-100 量化评分，基于互动频率、时效性、双向性、关系年龄
4. **会前简报** — 开会前自动准备参会者档案、上次互动、待办事项、建议话题
5. **AI 起草跟进** — 基于关系上下文和用户写作风格，生成个性化跟进消息草稿
6. **待办提取** — 自动识别邮件中的承诺和待办，追踪闭环，提醒逾期事项
7. **智能学习** — 从用户的 approve/reject 决策中学习联系人筛选偏好

## 工作流

### 每日定时任务（cron: `0 8 * * *`）

```
Step 1: 数据采集
  - 读取 Gmail 收发邮件（自 last_scan_time 以来）
  - 读取 Google Calendar 会议记录
  - 扫描 meeting-notes/ 目录下的新文件
  - 过滤已处理内容（检查 processed_email_ids）
  - 输出：raw_interaction_records

Step 2: 联系人解析与充实
  - 从 raw_interaction_records 提取人名、邮箱、公司
  - 查询 MEMORY.md 中的 contacts_db 进行去重
  - 合并重复身份（同一人不同邮箱/名称变体）
  - 新联系人触发充实流程：
    a. 解析邮件签名 → 提取职位、电话、公司
    b. 从邮件域名推断公司 → 抓取公司网站获取基本信息
    c. （可选）调用 Apollo.io 免费 API 补全 LinkedIn 等
  - 低置信度合并 → 记入 pending_merges，等待用户确认
  - 输出：resolved_contacts, new_contacts, updated_contacts, pending_merges

Step 3: 关系摘要与健康评分
  - 对有新互动的联系人更新关系摘要：
    - 最近互动概述
    - 当前合作阶段（初识/建立信任/深度合作/维护期/沉寂/重新激活）
    - 关键话题、机会、风险
  - 计算关系健康评分（0-100）：
    Score = Recency(40%) + Frequency(25%) + Responsiveness(20%) + Depth(15%)
    衰减规则：关系年龄 > 1年的联系人衰减慢（5%/月），< 3个月的衰减快（15%/月）
  - 检测状态变化：warming / cooling / escalation / de-escalation / reactivation
  - 输出：relationship_updates, status_changes, health_scores

Step 4: 待办提取
  - 从互动记录中提取：
    - 显式承诺（"我下周发给你"、"我来安排"）
    - 隐式期待（问题未回复、请求未响应）
  - 标记"沉默太久"的联系人（> 14 天无互动）
  - 检查历史待办是否已完成（闭环检测）
  - 输出：action_items, followup_reminders, stale_contacts

Step 5: 推送通知
  - 生成 Telegram 每日摘要（≤ 500 字）：
    1. 🔴 紧急跟进（逾期待办）
    2. 📋 今日跟进（到期提醒）
    3. 👤 新联系人（昨日新增）
    4. ⚠️ 关系预警（健康评分骤降）
    5. ❓ 待确认（合并建议等）
  - 推送到 Telegram
```

### 会前简报（事件触发：会议开始前 30 分钟）

```
Step 1: 读取今日日历，筛选外部会议（排除内部/例会/> 10 人）
Step 2: 对每个参会者：
  - 查询 contacts_db 获取档案
  - 拉取最近 3 次互动记录
  - 获取未闭环的待办事项
  - （可选）搜索公司近期新闻
Step 3: 生成结构化简报：
  - 参会者：姓名 | 职位 | 公司 | 关系健康分
  - 上次互动：日期 + 摘要
  - 待办事项：你欠他们什么 / 他们欠你什么
  - 建议话题：基于历史对话和待办推荐 2-3 个话题
Step 4: 推送到 Telegram
```

### AI 起草跟进消息（用户手动触发）

```
触发方式：用户说 "帮我给张三写个跟进" 或 "draft followup to Zhang San"

Step 1: 查询联系人档案 + 最近 3 次互动
Step 2: 读取用户写作风格档案（从 MEMORY.md）
Step 3: 确定消息上下文：
  - 关系阶段（决定正式/随意程度）
  - 未闭环事项（消息的核心内容）
  - 距上次联系的时间（决定开头语气）
Step 4: 生成草稿，呈现给用户编辑
Step 5: 用户确认后，保存为已发送互动记录
```

### 用户反馈学习（持续运行）

```
阶段 1（0-20 次决策）：
  - 每个新发现的联系人都通过 Telegram 询问用户 approve/reject
  - 预过滤：自动跳过 newsletter、noreply、自动化发件人、> 10 人会议

阶段 2（20-50 次决策）：
  - 开始显示置信度："我 80% 确定你会跳过这个人，对吗？"
  - 学习模式：域名模式、角色模式、互动频率模式

阶段 3（50+ 次决策）：
  - 建议切换到自动模式
  - 自动添加/跳过，每周推送一次"本周自动决策回顾"让用户修正
  - 用户修正会更新模式权重
```

## 数据结构

### 联系人档案（存储在 MEMORY.md）

```yaml
contact:
  id: "c_20260320_001"
  name: "张三"
  email: ["zhangsan@company.com", "zhangsan@gmail.com"]
  company: "ABC科技"
  title: "技术总监"
  linkedin: "linkedin.com/in/zhangsan"
  tags: ["客户", "技术决策者"]
  relationship_summary: "Q1 重点客户，正在评估 SaaS 方案。技术层面已认可，等待预算审批。"
  health_score: 72
  health_trend: "cooling"  # warming / stable / cooling
  current_stage: "深度合作"
  latest_interaction:
    date: "2026-03-18"
    type: "email"
    summary: "讨论二期开发排期"
  next_followup_date: "2026-03-22"
  key_topics: ["SaaS 迁移", "二期开发"]
  open_loops:
    - action: "发送需求文档"
      owner: "我"
      due: "2026-03-20"
    - action: "确认预算"
      owner: "张三"
      due: "2026-03-25"
  first_contact: "2025-11-15"
  interaction_count: 23
  created_at: "2025-11-15T09:30:00+13:00"
  updated_at: "2026-03-18T14:22:00+13:00"
```

### 关系健康评分算法

```
Score = Recency(40%) + Frequency(25%) + Responsiveness(20%) + Depth(15%)

Recency（时效性）:
  0-3 天 = 100, 4-7 天 = 85, 8-14 天 = 70, 15-21 天 = 50, 22-30 天 = 30, 31-60 天 = 15, 60+ 天 = 5
  使用线性插值，避免边界突变

Frequency（频率）:
  过去 90 天的互动次数: ≥12 = 100, 8-11 = 80, 4-7 = 60, 2-3 = 40, 1 = 20, 0 = 0

Responsiveness（双向性，双向比率 60% + 响应速度 40%）:
  双向比率: min(outbound,inbound)/max(outbound,inbound) → 0.8-1.0=100, 0.5-0.79=75, 0.2-0.49=40, <0.2=10
  平均响应时间: < 2小时 = 100, 2-8小时 = 80, 8-24小时 = 60, 1-3天 = 30, 3+天 = 10

Depth（深度）:
  会议 = 30分, 长邮件 = 20分, 短邮件 = 10分, 群发 = 5分（取最近 5 次互动均值，归一化到 100）

衰减修正：
  关系年龄 < 3 个月：衰减系数 1.5（快）
  关系年龄 3-12 个月：衰减系数 1.0（正常）
  关系年龄 > 1 年：衰减系数 0.6（慢，老朋友宽容度高）

评级：
  80-100 = 🟢 健康
  50-79  = 🟡 需要关注
  20-49  = 🟠 正在冷却
  0-19   = 🔴 即将断联
```

## 输出格式

### Telegram 每日摘要（≤ 500 字）

```
🤝 CRM 日报 | 2026-03-20

🔴 紧急跟进：
• 张三 - 需求文档今天截止 (健康: 72🟡)
• 李总 - 合同确认已逾期 2 天 (健康: 45🟠)

📋 今日跟进：
• 王总 - 轻量问候 _(16天未联系, 健康: 58🟡)_

👤 新联系人：
• 赵明 (产品经理@XYZ科技) — 来自昨日邮件

⚠️ 关系预警：
• 陈总 健康评分 68→52 _(回复变慢，可能有竞品介入)_

❓ 待确认：
• "zhangsan@gmail.com" 和 "张三@company.com" 是否同一人？
  /merge_yes  /merge_no
```

### 会前简报

```
📋 会前简报 | 14:00 客户需求对齐

👤 李总 | CTO | ABC科技 | 健康: 85🟢
  上次互动: 3月15日 讨论技术架构
  未闭环: 他答应发技术评审报告（逾期 3 天）
  建议话题: ① 跟进技术评审报告 ② 二期排期确认

👤 赵明 | 产品经理 | ABC科技 | 健康: --（新联系人）
  首次见面，无历史记录
  建议: 了解他在项目中的角色和决策权
```

## 配置

### 必需环境变量

| 变量 | 用途 | 获取方式 |
|------|------|---------|
| `GMAIL_OAUTH_CREDENTIALS` | Gmail 读取权限 | Google Cloud Console |
| `GOOGLE_CALENDAR_CREDENTIALS` | 日历读取权限 | Google Cloud Console |
| `TELEGRAM_BOT_TOKEN` | 推送通知 | @BotFather |
| `TELEGRAM_CHAT_ID` | 推送目标 | Telegram |

### 可选环境变量

| 变量 | 用途 | 说明 |
|------|------|------|
| `APOLLO_API_KEY` | 联系人充实 | 免费额度可用 |
| `BRAVE_SEARCH_API_KEY` | 公司信息搜索 | 免费 2000次/月 |
| `NOTION_API_KEY` | 同步到 Notion | 可选存储后端 |

### Cron 配置

```bash
# 每日 CRM 扫描 + 推送
openclaw cron add --name "crm-daily" --cron "0 8 * * *" \
  --tz "Pacific/Auckland" --session isolated \
  --message "运行 Self-Evolving CRM 每日扫描" --wake now

# 会前简报（每小时检查一次接下来的会议）
openclaw cron add --name "crm-meeting-prep" --cron "0 * * * *" \
  --tz "Pacific/Auckland" --session isolated \
  --message "检查接下来 60 分钟内的会议，生成简报" --wake now

# 每周关系健康报告
openclaw cron add --name "crm-weekly" --cron "0 9 * * 1" \
  --tz "Pacific/Auckland" --session isolated \
  --message "生成本周关系健康报告" --wake now
```

## 记忆管理

### MEMORY.md 存储内容

- `contacts_db`: 所有联系人档案（YAML 格式）
- `skip_patterns`: 学习到的跳过规则（域名、发件人模式）
- `writing_style`: 用户写作风格档案（问候语、签名、正式度、常用短语）
- `user_preferences`: 跟进阈值、关注的标签、通知偏好

### memory/ 日志

- `memory/YYYY-MM-DD.md`: 每日互动记录、新增联系人、状态变化日志

### 状态文件

- `~/.openclaw/workspace/self-evolving-crm/last_scan.json`: 上次扫描时间戳
- `~/.openclaw/workspace/self-evolving-crm/processed_ids.json`: 已处理邮件 ID
- `~/.openclaw/workspace/self-evolving-crm/decisions.json`: 用户 approve/reject 历史

## 护栏

- **只读邮件**：永远不发送邮件，只读取。起草的跟进消息必须由用户确认后手动发送
- **隐私优先**：所有数据存储在本地，不上传到任何外部服务
- **合并确认**：低置信度的联系人合并必须用户确认，不自动执行
- **健康评分透明**：每个评分都附带计算依据，不是黑箱
- **数据量限制**：processed_ids 最多保留 10,000 条（FIFO 淘汰）

## 故障处理

- Gmail API 失败 → 跳过邮件采集，用已有数据继续后续步骤，通知用户
- 联系人充实 API 失败 → 降级为仅邮件签名解析，标记"待充实"
- Telegram 推送失败 → 保存到本地 Markdown 文件作为备份
- 健康评分计算异常 → 保持上次评分不变，标记"待重新计算"

## 参考文档

详细的 Agent 角色定义和实现指南见 `{baseDir}/references/` 目录：

- `agent-data-collector.md` — 数据采集器详细规范
- `agent-enrichment.md` — 联系人充实详细规范
- `agent-relationship.md` — 关系摘要与健康评分详细规范
- `agent-action-extractor.md` — 待办提取详细规范
- `agent-meeting-prep.md` — 会前简报详细规范
- `agent-draft-writer.md` — AI 起草跟进详细规范
- `agent-notifier.md` — 通知推送详细规范
