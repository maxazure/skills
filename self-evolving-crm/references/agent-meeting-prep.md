# 会前简报 — 详细规范

> Agent 角色：Meeting Prep Agent
> 触发方式：Cron 定时任务（每小时一次）
> 输出通道：Telegram 推送

---

## 角色定义

会前简报 Agent 在会议开始前自动生成参会者简报，帮助用户在每次外部会议前快速回顾关系上下文、未闭环事项和建议话题，避免"这人是谁来着？上次聊了什么？"的尴尬。

设计参考：Dex CRM 的 pre-meeting briefs（会议前自动推送联系人卡片）、Tavily 的 meeting prep agent（基于搜索的参会者背景调研）、n8n 工作流模板（日历触发 + 多步数据聚合）。

---

## 触发机制

### Cron 配置

```bash
openclaw cron add --name "crm-meeting-prep" --cron "0 * * * *" \
  --tz "Pacific/Auckland" --session isolated \
  --message "检查接下来 60 分钟内的会议，生成简报" --wake now
```

### 触发逻辑

**时区**：所有时间使用配置的时区（Pacific/Auckland，NZST）。会议时间判断需考虑时区转换。

1. 每整点执行一次（每小时检查一次）
2. 读取 Google Calendar，筛选 **当前时间 ~ 当前时间 + 60 分钟** 内开始的会议
3. 对符合条件的会议生成简报
4. 在会议开始前 **30 分钟** 推送到 Telegram
5. 已推送的会议 ID 记录到 `sent_briefs` 集合，避免重复推送

### 时间窗口示例

```
当前时间: 13:00
扫描范围: 13:00 ~ 14:00
发现会议: 13:30 产品对齐会 → 立即推送（距会议 30 分钟）
发现会议: 13:50 客户电话 → 立即推送（距会议 50 分钟，在窗口内）
```

---

## 会议过滤规则

### 排除条件（满足任一即跳过）

| 规则 | 判断逻辑 | 原因 |
|------|----------|------|
| 内部会议 | 所有参会者邮箱域名相同（与用户主域名一致） | 内部同事不需要关系简报 |
| 例行站会 | 标题包含 standup / daily / 站会 / 日会 / sync，且为周期性事件 | 高频例会无需每次准备 |
| 大型会议 | 参会者 > 10 人 | 大型会议无法为每人准备简报，信息过载 |
| 已取消会议 | 事件状态为 cancelled | 无效事件 |
| 全天事件 | 事件类型为 all-day | 通常是提醒/节假日，不是真正的会议 |
| 已推送 | 会议 ID 在 `sent_briefs` 中 | 避免重复推送 |

### 保留条件（外部会议识别）

```python
def is_external_meeting(event, user_domain):
    attendees = event.get("attendees", [])
    if len(attendees) <= 1:
        return False  # 只有自己，不是会议
    if len(attendees) > 10:
        return False  # 大型会议排除
    domains = {parse_domain(a["email"]) for a in attendees}
    domains.discard(user_domain)
    return len(domains) > 0  # 存在非本域参会者
```

---

## 数据采集流程

对每个通过过滤的外部会议，按以下步骤采集参会者信息：

### Step 1: 查询联系人数据库

```
输入: attendee.email
查询: MEMORY.md → contacts_db
输出: contact_profile（如存在）或 null（新联系人）
```

对于新联系人（数据库中无记录），简报中标注"首次见面"，建议用户了解其角色。

### Step 2: 拉取最近 3 次互动

```yaml
查询条件:
  contact_id: "c_xxx"
  sort: interaction_date DESC
  limit: 3
返回字段:
  - date: 互动日期
  - type: email / meeting / call
  - summary: 互动摘要（≤ 50 字）
  - direction: inbound / outbound / bilateral
```

### Step 3: 获取未闭环待办

```yaml
查询条件:
  contact_id: "c_xxx"
  status: pending | waiting | overdue
分类:
  my_items: owner == "我" 的待办（我欠对方的）
  their_items: owner == 对方 的待办（对方欠我的）
```

### Step 4: 公司新闻搜索（可选）

仅在以下条件满足时执行：
- 环境变量 `BRAVE_SEARCH_API_KEY` 已配置
- 联系人有明确的公司信息
- 距上次搜索该公司 > 7 天

```bash
brave-search -n 3 -f pw -- "{company_name} 融资 OR 产品发布 OR 合作"
```

搜索结果缓存 7 天，避免重复消耗配额。

---

## 简报结构

### 参会者卡片

```
姓名 | 职位 | 公司 | 健康评分 | 关系阶段
```

健康评分使用对应 emoji：80+ 🟢 / 50-79 🟡 / 20-49 🟠 / 0-19 🔴 / 无记录 ⚪

### 关系上下文

- 认识渠道（如可追溯）：通过谁介绍、哪次会议认识
- 上次互动日期 + 摘要
- 关系存续时间（首次联系至今）

### 未闭环事项

- 我的待办：我承诺要做但未完成的事项，标注是否逾期
- 对方待办：对方承诺但未完成的事项

### 建议话题

基于以下信息自动生成 2-3 个话题建议：
1. 逾期待办 → "跟进 XX 进展"
2. 上次互动中提到的关键议题 → "继续讨论 XX"
3. 公司新闻 → "恭喜贵司 XX"
4. 关系冷却预警 → "近期联系较少，可以聊聊近况"

### 公司情报

最近的融资、产品发布、人事变动等新闻（如有）。

---

## Telegram 推送格式

```
📋 会前简报 | 14:00 客户需求对齐会
━━━━━━━━━━━━━━━━━━

👤 李总 | CTO | ABC科技 | 85🟢 | 深度合作
📅 认识 4 个月 | 上次: 3月15日
💬 上次聊了: 讨论技术架构选型，倾向微服务方案
📌 我欠他: 发送架构对比文档 (逾期2天❗)
📌 他欠我: 技术评审报告 (逾期3天)
💡 建议话题:
  1. 跟进架构对比文档（已逾期，优先处理）
  2. 询问技术评审报告进展
  3. 确认二期排期

👤 赵明 | 产品经理 | ABC科技 | ⚪ 新联系人
🆕 首次见面，无历史互动记录
💡 建议: 了解他在项目中的角色和决策权限

🏢 ABC科技 近期动态:
  • 3月12日 完成 B 轮融资 2000 万美元
```

---

## 输出格式（YAML 结构）

```yaml
meeting_brief:
  meeting_id: "cal_event_abc123"
  meeting_title: "客户需求对齐会"
  meeting_time: "2026-03-20T14:00:00+13:00"
  generated_at: "2026-03-20T13:30:00+13:00"
  attendees:
    - name: "李总"
      email: "li@abc-tech.com"
      title: "CTO"
      company: "ABC科技"
      health_score: 85
      health_emoji: "🟢"
      relationship_stage: "深度合作"
      known_since: "2025-11-20"
      last_interaction:
        date: "2026-03-15"
        type: "meeting"
        summary: "讨论技术架构选型，倾向微服务方案"
      open_loops:
        my_items:
          - action: "发送架构对比文档"
            due: "2026-03-18"
            status: "overdue"
        their_items:
          - action: "技术评审报告"
            due: "2026-03-17"
            status: "overdue"
      suggested_topics:
        - "跟进架构对比文档（已逾期，优先处理）"
        - "询问技术评审报告进展"
        - "确认二期排期"
    - name: "赵明"
      email: "zhaoming@abc-tech.com"
      title: null
      company: "ABC科技"
      health_score: null
      relationship_stage: "未知"
      is_new_contact: true
      suggested_topics:
        - "了解他在项目中的角色和决策权限"
  company_intel:
    - company: "ABC科技"
      news:
        - date: "2026-03-12"
          headline: "ABC科技完成 B 轮融资 2000 万美元"
          source: "36kr.com"
  delivery:
    channel: "telegram"
    delivered_at: "2026-03-20T13:30:05+13:00"
    message_id: "tg_msg_789"
```

---

## 边界情况处理

| 场景 | 处理方式 |
|------|----------|
| 参会者全部是新联系人 | 生成简化简报，标注"首次见面"，建议了解背景 |
| 参会者无邮箱（仅姓名） | 尝试在 contacts_db 中模糊匹配姓名，无结果则跳过 |
| 会议无标题 | 使用"未命名会议"作为标题 |
| 日历 API 不可用 | 跳过本次检查，记录错误日志，下次重试 |
| 简报内容超过 Telegram 4096 字符限制 | 分多条消息发送，按参会者拆分 |
| 同一小时有多个外部会议 | 每个会议生成独立简报，按时间顺序推送 |

---

## 状态管理

```yaml
# 存储在 ~/.openclaw/workspace/self-evolving-crm/meeting_prep_state.json
sent_briefs:
  - meeting_id: "cal_event_abc123"
    sent_at: "2026-03-20T13:30:05+13:00"
  # 仅保留最近 30 天的记录，自动清理更早的

company_news_cache:
  "ABC科技":
    fetched_at: "2026-03-15T08:00:00+13:00"
    news: [...]
  # 缓存 7 天后过期
```
