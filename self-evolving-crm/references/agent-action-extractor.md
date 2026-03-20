# 待办提取 — 详细规范

## 角色定义

待办提取（Action Extractor Agent）负责从互动记录中自动提取待办事项、跟进日期和承诺追踪。它确保每一个承诺都被记录和追踪，避免遗忘导致的关系损害。

**核心原则**：不遗漏承诺，准确推断时间，闭环追踪。

---

## 四类待办检测

### 1. 显式承诺检测

从邮件/会议纪要中识别明确的行动承诺。

**中文触发短语**：

```yaml
outbound_commitments:  # 我方承诺
  - "我来.*"           # 我来安排、我来确认
  - "我会.*"           # 我会发给你、我会跟进
  - "我下周.*"         # 我下周发给你
  - "稍后.*发"         # 稍后发给你
  - "回头.*"           # 回头确认一下
  - "我这边.*处理"     # 我这边尽快处理
  - "等我.*"           # 等我确认后回复你
  - "我.*之前.*给你"   # 我周五之前给你答复

inbound_commitments:  # 对方承诺
  - "我.*发给你"       # 对方说的"我来发给你"
  - "我.*安排"
  - "下周.*给你"
  - "回头.*联系你"
  - "等.*确认后.*通知"
```

**英文触发短语**：

```yaml
outbound_commitments:
  - "I'll .*"            # I'll send you, I'll check
  - "I will .*"
  - "Let me .*"          # Let me check, Let me get back
  - "I can .*"           # I can arrange that
  - "Will do"
  - "I'll get back to you"
  - "I'll follow up"

inbound_commitments:
  - "I'll send you"
  - "Let me check"
  - "I will .* by .*"
  - "We'll get back"
```

**LLM 辅助提取 Prompt**：

```
分析以下互动内容，提取所有行动承诺。

互动内容：{interaction_content}
发送者：{sender}（我方 / 对方）

对每个承诺，提取：
1. action: 具体要做什么
2. owner: 谁负责（"self" 或联系人姓名）
3. due_hint: 原文中的时间线索（如"下周"、"月底"、"尽快"）
4. confidence: 是否确实是承诺（high/medium/low）

仅提取明确的行动承诺，忽略客套话（如"有空再聊"、"改天约"等模糊表达）。
```

### 2. 隐式期望检测

未被回复的问题和请求：

```yaml
detection_rules:
  unanswered_questions:
    - "对方邮件以 ? 或 ？ 结尾的句子"
    - "包含: 能否/是否/可以吗/what/how/when/could you"
    - "检查后续邮件是否有回复 → 无回复则生成待办"
    - "时限: 问题发出后 48 小时未回复自动标记"

  unresponded_requests:
    - "请.*发 / 麻烦.* / 帮.*"
    - "Could you / Can you / Please send"
    - "带附件请求: 见附件 / attached"
    - "检查是否有后续行动 → 无则生成待办"
```

### 3. 沉寂联系人检测

自动检测需要主动跟进的联系人：

```yaml
stale_contact_rules:
  - condition: "最后互动距今 > 14 天"
    action: "生成跟进提醒"
    priority: "medium"
    exclude:
      - 关系阶段为 "沉寂" 且用户未标记为重要
      - 健康评分 < 20（已知不活跃）
      - 用户手动设置了 "免打扰" 标签

  - condition: "最后互动距今 > 7 天 AND 关系阶段为 '深度合作'"
    action: "生成紧急跟进提醒"
    priority: "high"
    message: "深度合作中的联系人已 {days} 天无互动，建议主动联系"

  - condition: "关系阶段为 '初识' AND 首次互动后 > 5 天无后续"
    action: "生成跟进提醒"
    priority: "medium"
    message: "新认识的联系人可能需要后续跟进以建立关系"
```

### 4. 闭环检测

追踪历史承诺是否已完成：

```yaml
closure_detection:
  email_attachment_promise:
    trigger: "承诺发送文件/文档/报告"
    check: "后续邮件是否包含附件 或 提到了共享链接"
    match_window: "承诺后 7 天内"

  meeting_schedule_promise:
    trigger: "承诺安排会议"
    check: "日历中是否出现与该联系人的新会议"
    match_window: "承诺后 14 天内"

  response_promise:
    trigger: "承诺回复/确认"
    check: "是否有后续邮件回复"
    match_window: "承诺后 5 天内"

  generic_promise:
    trigger: "其他类型承诺"
    check: "后续互动中是否提到相关内容"
    match_window: "承诺后 14 天内"
    fallback: "超过时限未检测到闭环 → 标记为 overdue"
```

**闭环判定 Prompt**：

```
历史承诺：{action_item}
后续互动记录：{subsequent_interactions}

判断这个承诺是否已经完成。返回：
- status: "completed" | "in_progress" | "overdue" | "unknown"
- evidence: 哪条互动记录表明已完成（如有）
- confidence: high | medium | low
```

---

## 时间推断规则

将模糊时间表述转换为具体日期：

| 表述 | 推断规则 | 示例（当前 2026-03-20 周五） |
|------|----------|------------------------------|
| 今天 / today | 当天 | 2026-03-20 |
| 明天 / tomorrow | +1 天 | 2026-03-21 |
| 下周 / next week | 下周一 | 2026-03-23 |
| 下周X / next Monday | 下周对应星期 | 下周三 = 2026-03-25 |
| 这周内 / this week | 本周五 | 2026-03-20 |
| 月底 / end of month | 当月最后一天 | 2026-03-31 |
| 月初 / early next month | 下月 1 日 | 2026-04-01 |
| 尽快 / ASAP | +3 个工作日 | 2026-03-25 |
| 近期 / soon | +5 个工作日 | 2026-03-27 |
| 两周内 / within 2 weeks | +14 天 | 2026-04-03 |
| 季度末 / end of quarter | 当季最后一天 | 2026-03-31 |
| 无时间线索 | 默认 +7 天 | 2026-03-27 |

### 工作日计算

- 跳过周六、周日
- 不考虑法定节假日（简化处理）
- 如果推算日期落在周末，自动推到下周一

---

## 优先级矩阵

```
P1 (critical): 已逾期
    ↓
P2 (high):     今天到期
    ↓
P3 (medium):   本周到期（7 天内）
    ↓
P4 (low):      下周到期（8-14 天内）
    ↓
P5 (minimal):  无明确日期 或 14 天以后
```

### 优先级动态调整

| 条件 | 调整 |
|------|------|
| 联系人处于"深度合作"阶段 | 优先级 +1 级 |
| 对方承诺（而非我方） | 优先级 -1 级（仅追踪，不急迫） |
| 连续 2 次未完成的承诺 | 优先级 +1 级（诚信风险） |
| 金额/合作相关关键词 | 优先级 +1 级 |
| 用户手动标记重要 | 强制 P1 |

---

## 输出格式

### 单条待办

```yaml
action_item:
  id: "action_20260320_001"
  contact_id: "contact_zhangsan_001"
  contact_name: "张三"

  action: "发送 API 集成方案的技术文档"
  owner: "self"  # self | contact_name
  type: "explicit_commitment"  # explicit_commitment | implicit_expectation | stale_followup | overdue_closure

  due_date: "2026-03-25"
  due_source: "原文：'我下周发给你' → 推断为下周一"
  priority: "P3"  # P1-P5

  source_interaction:
    id: "ir_20260320_gmail_abc123"
    type: "email"
    date: "2026-03-20"
    excerpt: "...我下周把技术文档整理好发给你..."

  status: "pending"  # pending | completed | overdue | cancelled
  created_at: "2026-03-20T10:00:00+12:00"
  completed_at: null

  closure_check:
    next_check_date: "2026-03-26"
    check_method: "检查是否有发送附件的后续邮件"
```

### 每日待办汇总

```yaml
daily_action_summary:
  date: "2026-03-20"
  generated_at: "2026-03-20T08:00:00+12:00"

  overdue:  # P1
    count: 2
    items:
      - id: "action_20260315_003"
        contact: "王五"
        action: "回复他关于报价的问题"
        due_date: "2026-03-18"
        overdue_days: 2

  due_today:  # P2
    count: 1
    items:
      - id: "action_20260318_001"
        contact: "李四"
        action: "发送修改后的合同草稿"

  due_this_week:  # P3
    count: 3
    items: [...]

  stale_contacts:
    count: 5
    items:
      - contact: "赵六"
        last_interaction: "2026-03-04"
        days_silent: 16
        relationship_stage: "建立信任"
        suggestion: "发一封简短的问候邮件，询问上次讨论的项目进展"

  completed_today:
    count: 1
    items:
      - id: "action_20260318_002"
        contact: "张三"
        action: "确认会议时间"
        completed_evidence: "邮件回复中确认了周三下午 2 点"

  stats:
    total_pending: 11
    completion_rate_7d: 0.78  # 过去 7 天完成率
    avg_completion_days: 2.3
```

---

## 防重复机制

避免同一承诺被重复提取：

```yaml
dedup_rules:
  - 同一 thread_id 中相同 owner + 相似 action（LLM 判定相似度 > 0.8）→ 合并
  - 同一联系人 3 天内相同类型待办 → 合并为一条，保留最早的 due_date
  - 闭环检测标记为 completed 的不再重新生成
```

### 相似度判定 Prompt

```
判断以下两个待办事项是否指向同一件事：

待办 A: {action_a}
待办 B: {action_b}

返回：
- is_same: true/false
- confidence: 0-1
- reason: 简短解释
```

---

## 用户交互命令

```bash
# 查看今日待办
openclaw todo

# 查看所有待办（含未来）
openclaw todo --all

# 标记完成
openclaw todo done action_20260320_001

# 推迟
openclaw todo snooze action_20260320_001 --to 2026-03-25

# 取消
openclaw todo cancel action_20260320_001 --reason "项目已取消"

# 手动添加
openclaw todo add --contact zhangsan@acme.com "跟进合作方案" --due 2026-03-25
```

---

## 提取触发时机

| 触发条件 | 行为 |
|----------|------|
| 新互动记录到达 | 立即分析该条记录，提取待办 |
| 每日早 8 点 | 生成每日待办汇总 |
| 每日检查一次 | 扫描所有 pending 状态待办，执行闭环检测 |
| 手动触发 | `openclaw extract --from interaction_id` |

---

## 错误处理

| 场景 | 处理 |
|------|------|
| LLM 返回格式异常 | 回退到正则匹配，标记 `extraction_quality: low` |
| 时间推断冲突（如"下周"出现在周五 vs 周一含义不同） | 取更保守的日期（更早） |
| 联系人无法识别 | 创建临时联系人记录，标记 `needs_resolution` |
| 同一邮件提取出过多待办（> 5 条） | 保留置信度最高的 5 条，其余降级为 `low_confidence` |
