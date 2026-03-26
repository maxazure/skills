# AI 起草跟进消息 — 详细规范

> Agent 角色：Draft Writer Agent
> 触发方式：用户手动请求
> 输出通道：对话内呈现草稿，用户确认后记录为互动

---

## 角色定义

Draft Writer Agent 基于关系上下文生成个性化跟进消息草稿。它不是通用的"帮我写封邮件"，而是深度结合联系人档案、互动历史、未闭环事项和用户个人写作风格，生成一封"像你自己写的"跟进消息。

设计参考：Folk CRM 的 follow-up assistant（基于 CRM 数据自动起草跟进）、Clay AI messaging（根据联系人画像个性化消息）、Fyxer AI（学习用户写作风格后代写邮件）。

---

## 触发方式

### 用户指令格式

```
"帮我给张三写个跟进"
"draft followup to Zhang San"
"给李总写封邮件，关于合同的事"
"帮我写个消息给 sarah@startup.io"
"/draft 张三"（Telegram 命令）
```

### 参数解析

```yaml
必需参数:
  contact: 联系人姓名、邮箱或 ID（模糊匹配）
可选参数:
  topic: 指定话题（如"关于合同的事"）
  channel: 指定渠道（email / telegram / linkedin），默认 email
  tone: 覆盖语气（formal / casual / urgent）
  language: 指定语言（zh / en），默认跟随联系人历史互动语言
```

---

## 上下文采集

### Step 1: 联系人档案

```yaml
读取字段:
  - name, title, company
  - current_stage: 关系阶段（初识/建立信任/深度合作/维护期/沉寂/重新激活）
  - health_score: 健康评分
  - health_trend: 趋势（warming / stable / cooling）
  - key_topics: 关键话题列表
  - tags: 标签（客户/合作方/投资人等）
```

### Step 2: 最近 3 次互动

```yaml
读取字段:
  - date: 互动日期
  - type: email / meeting / call
  - summary: 摘要
  - direction: inbound / outbound / bilateral
  - key_points: 关键内容点（如有）
  - language: 互动使用的语言
```

### Step 3: 未闭环事项

```yaml
分类:
  my_pending: 我承诺但未完成的（消息中需要交代进展或道歉）
  their_pending: 对方承诺但未完成的（消息中可以礼貌催促）
  shared_items: 双方共同推进的事项
```

### Step 4: 用户写作风格档案

从 MEMORY.md 的 `writing_style` 字段读取。

---

## 写作风格学习

### 风格分析方法（参考 Fyxer AI）

从用户已发送的邮件中分析以下维度：

```yaml
writing_style:
  # 基于 50-100 封已发送邮件分析
  sample_size: 87
  last_analyzed: "2026-03-15"

  greeting_patterns:
    zh_formal: "XX 您好，"          # 正式场合
    zh_casual: "XX，"               # 熟悉的人
    en_formal: "Dear XX,"
    en_casual: "Hi XX,"

  signoff_patterns:
    zh_formal: "祝好\n{user_name}"
    zh_casual: "谢谢！"
    en_formal: "Best regards,\n{user_name}"
    en_casual: "Thanks!\n{user_name}"

  formality_score: 0.6              # 0=极随意, 1=极正式
  avg_sentence_length: 18           # 平均句子字数
  emoji_usage: "minimal"            # none / minimal / moderate / heavy
  common_phrases:                   # 用户高频使用的短语
    - "方便的话"
    - "麻烦帮忙"
    - "期待您的反馈"
    - "有空聊一下"
  paragraph_style: "short"          # short（每段1-2句）/ medium / long
  punctuation_style: "standard"     # 有的人喜欢用"～"、"！！"等
  language_preference:
    default: "zh"
    with_foreigners: "en"
```

### 风格学习触发

**时区**：时间计算使用 NZST（Pacific/Auckland）。"距上次联系时间"按自然天计算。

```
首次运行: 扫描最近 100 封已发送邮件，提取风格特征
增量更新: 每月重新分析一次（或用户手动触发 "更新我的写作风格"）
用户修正: 用户编辑草稿后，对比差异，更新风格权重
```

### 风格提示词构造

```
将风格档案转化为 system prompt 前缀：
"你正在模仿以下写作风格生成消息：
- 问候语使用 '{greeting_pattern}'
- 签名使用 '{signoff_pattern}'
- 正式度: {formality_score}（0=极随意, 1=极正式）
- 平均句子长度约 {avg_sentence_length} 字
- Emoji 使用程度: {emoji_usage}
- 常用短语: {common_phrases}
- 段落风格: {paragraph_style}"
```

---

## 消息生成规则

### 正式度由关系阶段决定

| 关系阶段 | 正式度 | 称呼示例 | 说明 |
|----------|--------|----------|------|
| 初识 | 高 | "XX 您好" | 第一次或刚认识，保持礼貌距离 |
| 建立信任 | 中高 | "XX 你好" | 已有几次互动，但尚未深入 |
| 深度合作 | 中 | "XX，" | 频繁合作，直接切入正题 |
| 维护期 | 中低 | "XX，" | 老关系维护，语气轻松 |
| 沉寂 | 中高 | "XX 你好" | 久未联系，重新建立连接 |
| 重新激活 | 中 | "XX，" | 刚恢复联系，逐步回到熟悉节奏 |

### 开头由距上次联系时间决定

| 时间间隔 | 开头策略 | 示例 |
|----------|----------|------|
| 0-3 天 | 直接切入，无需寒暄 | "关于昨天讨论的 XX..." |
| 4-14 天 | 简短承接上文 | "上次聊到的 XX，这边有个更新..." |
| 15-30 天 | 轻量问候 + 切入 | "最近怎么样？想跟你聊一下 XX 的进展..." |
| 31-90 天 | 温暖重连 | "好久没联系了！最近看到你们公司 XX，想起了..." |
| 90+ 天 | 正式重新建联 | "XX 你好，好久不见。之前我们在 YY 场合有过交流..." |

### 内容规则

1. **必须包含具体上下文**：引用上次互动的具体内容，不写"之前聊的那件事"这种模糊表述
2. **必须有明确目的**：每封消息都要有 clear ask 或 clear purpose
3. **禁止编造事实**：只能使用互动历史中存在的信息，不虚构未发生的事
4. **未闭环事项优先**：如果有逾期的我方待办，消息开头先交代进展或致歉
5. **长度适配渠道**：邮件 150-300 字 / Telegram 50-100 字 / LinkedIn 80-150 字
6. **语言跟随历史**：与该联系人历史互动使用的语言保持一致

---

## 输出格式

### 草稿呈现

```yaml
draft:
  to: "张三"
  email: "zhangsan@company.com"
  channel: "email"
  subject: "需求文档已整理完毕 — 二期开发排期"
  body: |
    张三，

    上周讨论的二期开发需求文档我已经整理好了，附在邮件里供你参考。

    主要更新了三个部分：
    1. 用户认证模块的详细需求
    2. 数据迁移方案的时间估算
    3. 第三方接口对接清单

    另外，上次提到的预算审批那边有进展吗？如果方便的话可以同步一下，
    这样我们好提前安排开发团队的排期。

    方便的话这周找个时间对齐一下？

    祝好
    Max
  metadata:
    confidence: 0.85            # 生成置信度
    tone: "professional-warm"   # 检测到的语气
    word_count: 142
    suggested_subject: "需求文档已整理完毕 — 二期开发排期"
    context_used:
      - "2026-03-15 会议: 讨论二期开发排期"
      - "未闭环: 我方待发送需求文档(逾期)"
      - "未闭环: 对方待确认预算审批"
    warnings: []                # 如有风险提示会列出
```

### 风险提示（warnings）

```yaml
warnings:
  - type: "long_gap"
    message: "距上次联系已 45 天，建议先发一条轻量问候再进入正题"
  - type: "cooling_relationship"
    message: "关系健康评分近期下降（72→52），建议语气更积极主动"
  - type: "overdue_item"
    message: "你有一项逾期 5 天的待办，建议在消息中主动说明"
```

---

## 用户交互流程

```
Step 1: 用户请求 → "帮我给张三写个跟进"
Step 2: Agent 采集上下文（联系人档案 + 互动 + 待办 + 风格）
Step 3: 生成草稿，呈现给用户

Step 4: 用户选择
  ├─ 直接确认 → Step 5
  ├─ 编辑后确认 → 记录编辑差异用于风格学习 → Step 5
  ├─ 要求重写 → 用户提供修改方向 → 回到 Step 3
  └─ 放弃 → 结束，不记录

Step 5: 确认后处理
  - 记录为新的互动（type: "email_draft_sent"）
  - 更新联系人的 latest_interaction
  - 更新相关未闭环事项状态
  - 重新计算 next_followup_date
```

---

## 多渠道适配

### 邮件（默认）

```yaml
format:
  max_length: 300 字
  include_subject: true
  include_greeting: true
  include_signoff: true
  paragraph_breaks: true
  attachments_hint: true    # 提示是否需要附件
```

### Telegram 消息

```yaml
format:
  max_length: 100 字
  include_subject: false
  include_greeting: "简短"  # "张三，" 而非 "张三您好，"
  include_signoff: false
  paragraph_breaks: false   # 紧凑排列
  emoji_ok: true
```

### LinkedIn 消息

```yaml
format:
  max_length: 150 字
  include_subject: false
  include_greeting: true
  include_signoff: "简短"
  professional_tone: true   # LinkedIn 场景偏正式
  no_attachments: true      # LinkedIn 消息不支持附件
```

---

## 边界情况处理

| 场景 | 处理方式 |
|------|----------|
| 联系人无互动记录 | 提示用户提供上下文："你想和 XX 聊什么？你们是怎么认识的？" |
| 互动记录只有 1 条 | 基于仅有的互动生成，标注"可用上下文有限，请仔细检查" |
| 用户未指定话题 | 从未闭环事项中推断，如无待办则建议轻量问候 |
| 同名联系人多个 | 列出候选人让用户选择（显示公司/邮箱以区分） |
| 写作风格档案为空 | 使用中性正式风格，首次生成后提示用户"要不要我学习你的写作风格？" |
| 用户要求的语气与关系阶段矛盾 | 以用户显式指定为准，但给出温和提示 |

---

## 风格学习的持续优化

```
每次用户编辑草稿后:
  1. 对比原始草稿和用户最终版本
  2. 提取差异:
     - 问候语是否被修改？
     - 签名是否被修改？
     - 语气是否调整？（正式→随意 或反之）
     - 是否删除了某些表达？
     - 是否添加了特定短语？
  3. 更新 writing_style 中对应字段的权重
  4. 累计 10 次编辑后，自动重新生成风格档案摘要
```

这种"生成→用户修正→学习"的闭环，使草稿质量随时间持续提升。
