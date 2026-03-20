# 关系摘要与健康评分 — 详细规范

## 角色定义

关系摘要与健康评分（Relationship Agent）负责为每个联系人生成可读的关系摘要，并计算量化的健康评分（0-100）。它是 CRM 的"分析大脑"，将原始互动数据转化为可操作的关系洞察。

**核心原则**：量化关系状态，预测衰退趋势，主动推送维护提醒。

---

## 关系摘要

### 摘要内容结构

每个联系人的关系摘要包含以下模块：

```yaml
relationship_summary:
  contact_id: "contact_zhangsan_001"
  generated_at: "2026-03-20T10:00:00+12:00"

  overview: "张三是 Acme 科技的技术总监，过去 3 个月有 12 次互动，关系处于深度合作阶段。"

  recent_interactions:
    - "2026-03-18: 邮件讨论 API 集成方案，他提出了性能优化建议"
    - "2026-03-12: 视频会议 45 分钟，确认了 Q2 合作时间线"
    - "2026-03-05: 他转发了竞品分析报告"

  current_stage: "深度合作"
  stage_since: "2026-01-15"

  key_topics:
    - "API 集成项目"
    - "Q2 合作方案"
    - "技术架构评审"

  opportunities:
    - "他提到团队在招 DevOps，可以推荐人选建立好感"
    - "Q2 项目如果顺利，可能扩展到 Q3 更大的合作"

  risks:
    - "上次邮件提到预算审批可能延迟"
    - "他的回复速度从平均 2 小时降到了 8 小时"

  next_action_suggestion: "本周内跟进 API 集成方案的技术细节"
```

### 摘要生成 Prompt

```
基于以下联系人的互动历史，生成关系摘要。

联系人：{contact_profile}
最近 30 天互动记录：{recent_interactions}
历史关系阶段：{stage_history}
上次摘要：{previous_summary}

要求：
1. overview: 一句话概括关系现状（30字以内）
2. recent_interactions: 最近 3 次互动的要点
3. key_topics: 当前活跃话题（最多 5 个）
4. opportunities: 可以深化关系的机会点
5. risks: 需要注意的风险信号
6. next_action_suggestion: 具体、可执行的下一步建议
```

---

## 六阶段关系模型

```
初识 → 建立信任 → 深度合作 → 维护期 → 沉寂 → 重新激活
 │       │          │         │       │        │
 └─ 首次互动后自动进入                         └─ 沉寂后再次互动
```

### 阶段定义与转换条件

| 阶段 | 定义 | 进入条件 | 典型健康分 |
|------|------|----------|-----------|
| 初识 | 刚认识，1-2 次互动 | 首次互动 | 40-60 |
| 建立信任 | 互动频率增加，开始有实质内容 | 3+ 次互动，且有双向交流 | 55-75 |
| 深度合作 | 频繁互动，涉及具体项目/合作 | 7+ 次互动，含会议或长邮件 | 70-95 |
| 维护期 | 合作稳定，互动频率适中 | 关系存续 > 6 个月，互动稳定 | 50-80 |
| 沉寂 | 长时间无互动 | > 30 天无任何互动 | 10-40 |
| 重新激活 | 沉寂后恢复互动 | 沉寂期后出现新互动 | 45-65 |

### 阶段判定逻辑

```python
def determine_stage(contact):
    days_since_last = (now - contact.last_interaction).days
    total_interactions = contact.interaction_count
    relationship_age_months = (now - contact.first_interaction).days / 30
    has_meetings = contact.meeting_count > 0
    is_bidirectional = contact.outbound_count > 0 and contact.inbound_count > 0

    if contact.previous_stage == "沉寂" and days_since_last < 7:
        return "重新激活"
    if days_since_last > 30:
        return "沉寂"
    if total_interactions >= 7 and has_meetings and is_bidirectional:
        return "深度合作"
    if relationship_age_months > 6 and total_interactions >= 10:
        return "维护期"
    if total_interactions >= 3 and is_bidirectional:
        return "建立信任"
    return "初识"
```

---

## 健康评分算法

总分 = Recency (40%) + Frequency (25%) + Responsiveness (20%) + Depth (15%)

### 1. Recency 评分（40%）

距离最近一次互动的天数：

| 天数范围 | 得分 | 说明 |
|----------|------|------|
| 0-3 天 | 100 | 非常活跃 |
| 4-7 天 | 85 | 活跃 |
| 8-14 天 | 70 | 正常 |
| 15-21 天 | 50 | 开始降温 |
| 22-30 天 | 30 | 需要关注 |
| 31-60 天 | 15 | 沉寂 |
| 60+ 天 | 5 | 严重沉寂 |

**注意**：使用线性插值而非阶梯函数，避免分数在边界处突变。

### 2. Frequency 评分（25%）

过去 90 天内的互动次数：

| 互动次数 | 得分 | 说明 |
|----------|------|------|
| 12+ 次 | 100 | 每周 1 次以上 |
| 8-11 次 | 80 | 约每周 1 次 |
| 4-7 次 | 60 | 约每两周 1 次 |
| 2-3 次 | 40 | 约每月 1 次 |
| 1 次 | 20 | 稀少 |
| 0 次 | 0 | 无互动 |

### 3. Responsiveness 评分（20%）

双向性和响应速度的综合评估：

**双向比率（占 Responsiveness 的 60%）**：

```
bidirectional_ratio = min(outbound, inbound) / max(outbound, inbound)
```

| 比率 | 得分 | 含义 |
|------|------|------|
| 0.8-1.0 | 100 | 均衡互动 |
| 0.5-0.79 | 75 | 略有偏向 |
| 0.2-0.49 | 40 | 明显单向 |
| 0-0.19 | 10 | 几乎单向 |

**平均响应时间（占 Responsiveness 的 40%）**：

| 响应时间 | 得分 |
|----------|------|
| < 2 小时 | 100 |
| 2-8 小时 | 80 |
| 8-24 小时 | 60 |
| 1-3 天 | 30 |
| 3+ 天 | 10 |

### 4. Depth 评分（15%）

互动类型的深度加权：

| 互动类型 | 权重 | 说明 |
|----------|------|------|
| 线下会面 | 10 | 最深度的互动 |
| 视频/电话会议 | 8 | 面对面沟通 |
| 长邮件（>200字） | 5 | 有实质内容 |
| 短邮件（<=200字） | 2 | 快速交流 |
| 群组邮件/会议 | 1 | 参与但非主要 |

```
depth_score = sum(interaction_weight) / max_possible_weight_for_period * 100
```

取过去 90 天内所有互动的加权总和，上限为 100。

### 评分计算示例

```yaml
example_calculation:
  contact: "张三"
  recency:
    days_since_last: 5
    raw_score: 85
    weighted: 85 * 0.40 = 34.0
  frequency:
    interactions_90d: 8
    raw_score: 80
    weighted: 80 * 0.25 = 20.0
  responsiveness:
    bidirectional_ratio: 0.7
    ratio_score: 75
    avg_response_hours: 4
    response_score: 80
    combined: 75 * 0.6 + 80 * 0.4 = 77
    weighted: 77 * 0.20 = 15.4
  depth:
    meetings: 2 (weight 16)
    long_emails: 3 (weight 15)
    short_emails: 5 (weight 10)
    total_weight: 41
    raw_score: 82  # 41/50*100, capped at 100
    weighted: 82 * 0.15 = 12.3

  total_health_score: 81.7  # 四舍五入为 82
```

---

## 衰减公式

健康评分随时间自然衰减，衰减速率根据关系年龄调整（参考 Realvolve 模型）：

### 关系年龄与衰减率

| 关系年龄 | 月衰减率 | 日衰减率 | 说明 |
|----------|----------|----------|------|
| < 3 个月（新关系） | 15% | 0.54% | 新关系容易冷却 |
| 3-12 个月（中等） | 10% | 0.35% | 有一定基础 |
| > 12 个月（长期） | 5% | 0.17% | 深度信任难以消失 |

### 衰减计算

```
daily_decay_rate = monthly_decay_rate / 30
decayed_score = current_score * (1 - daily_decay_rate) ^ days_since_last_calculation
```

### 衰减下限

- 最低分不低于 5（完全失联也保留微弱记录）
- 有过深度合作阶段的联系人，下限为 10
- 衰减只影响 Recency 和 Frequency 分量，Depth 历史分量不衰减

---

## 状态变化检测

系统检测 6 种关系状态变化，每种都触发特定通知：

### 变化类型与信号

| 变化类型 | 检测信号 | 触发阈值 | 通知优先级 |
|----------|----------|----------|-----------|
| warming（升温） | 互动频率增加 | 本周互动 >= 上周 2 倍 | info |
| cooling（降温） | 互动频率下降 | 连续 14 天无互动 且 前 14 天有 3+ 次互动 | warning |
| escalation（升级） | 关系阶段上升 | 阶段从低到高变化 | info |
| de-escalation（降级） | 关系阶段下降 | 阶段从高到低变化 | warning |
| reactivation（重新激活） | 沉寂后恢复 | 沉寂 30+ 天后出现新互动 | info |
| stable（稳定） | 无明显变化 | 连续 30 天健康分波动 < 5 分 | none |

### 各类型信号详解

**warming 信号**：
- 对方主动发起邮件（之前多为你发起）
- 邮件回复速度加快
- 会议邀请增加
- 邮件内容变长、更具实质性

**cooling 信号**：
- 你的邮件未得到回复
- 回复速度明显变慢（从小时级到天级）
- 回复内容变短
- 会议被取消或推迟
- 转为 CC 而非直接 To

**reactivation 信号**：
- 沉寂联系人主动发来邮件
- 在日历中出现与沉寂联系人的新会议

---

## 输出格式

```yaml
relationship_update:
  contact_id: "contact_zhangsan_001"
  timestamp: "2026-03-20T10:00:00+12:00"

  health_score:
    total: 82
    breakdown:
      recency: 85
      frequency: 80
      responsiveness: 77
      depth: 82
    previous_score: 78
    score_change: +4
    trend: "warming"  # warming | cooling | stable

  stage:
    current: "深度合作"
    previous: "建立信任"
    changed: true
    changed_at: "2026-03-15"

  decay_info:
    relationship_age_months: 4
    decay_rate_monthly: 10
    days_until_warning: 12  # 按当前衰减率，多少天后降到 warning 阈值

  status_changes:
    - type: "escalation"
      description: "关系从'建立信任'升级为'深度合作'"
      detected_at: "2026-03-15"
    - type: "warming"
      description: "本周互动频率是上周的 3 倍"
      detected_at: "2026-03-18"

  summary: "张三的关系持续升温，已进入深度合作阶段。健康评分 82 分（+4），建议保持当前互动节奏。"

  alerts:
    - level: "info"
      message: "关系升级为深度合作，建议安排一次正式合作规划会议"
```

---

## 批量评估与排序

### 仪表盘视图

每次运行生成全局关系概览：

```yaml
dashboard:
  total_contacts: 156
  active_contacts: 42  # 30 天内有互动

  score_distribution:
    excellent (80-100): 8
    good (60-79): 15
    fair (40-59): 19
    poor (20-39): 28
    critical (0-19): 86

  attention_needed:
    - contact: "李四"
      score: 35
      reason: "cooling - 从每周互动降为 21 天无互动"
    - contact: "王五"
      score: 28
      reason: "de-escalation - 从深度合作降为沉寂"

  top_relationships:
    - contact: "张三"
      score: 82
      stage: "深度合作"
    - contact: "赵六"
      score: 78
      stage: "维护期"
```

### Dunbar 层级（参考 PingCRM 模型）

基于邓巴数理论，将联系人分为关注层级：

| 层级 | 人数上限 | 含义 | 建议互动频率 |
|------|----------|------|-------------|
| 核心圈 | 5 人 | 最重要的关系 | 每周 |
| 内圈 | 15 人 | 密切合作伙伴 | 每两周 |
| 外圈 | 50 人 | 重要联系人 | 每月 |
| 认识圈 | 150 人 | 认识但不频繁互动 | 每季度 |
| 档案 | 无限 | 历史联系人 | 无主动维护 |

层级自动分配基于健康评分和互动频率，用户可手动调整。

---

## 计算频率

| 场景 | 频率 |
|------|------|
| 新互动触发 | 实时重算该联系人 |
| 每日衰减 | 每日凌晨批量更新所有活跃联系人 |
| 全量刷新 | 每周一次，重算所有联系人 |
| 手动请求 | `openclaw score zhangsan@acme.com` |
