# 数据采集器 — 详细规范

## 角色定义

数据采集器（Data Collector Agent）负责从多个数据源读取原始互动数据，将其标准化为统一的交互记录格式，供下游 Agent 处理。它是整个 CRM 数据管道的入口。

**核心原则**：只读不写，增量扫描，容错优先。

---

## 数据源 1：Gmail 扫描

### 扫描范围

- 扫描文件夹：`INBOX` + `SENT`
- 时间范围：从 `last_scan_time` 到当前时间
- 使用 Gmail API `messages.list` + `messages.get`，配合 `after:` 查询参数

### 提取字段

| 字段 | 提取方式 |
|------|----------|
| sender | `From` header，解析为 `name <email>` |
| receiver | `To` + `Cc` header，多个收件人拆分为数组 |
| subject | `Subject` header |
| body_snippet | 取正文前 500 字符，strip HTML 标签 |
| date | `Date` header，转为 ISO 8601 格式 |
| message_id | Gmail `id` 字段 |
| thread_id | Gmail `threadId`，用于关联同一对话 |
| has_attachment | 检查 `parts` 中 `filename` 是否非空 |
| direction | sender 是否为用户自己 → `outbound`，否则 → `inbound` |

### 过滤规则

**时区注意**：Gmail API 返回的时间戳为 UTC。所有日期计算使用 NZST（Pacific/Auckland，时区 +12/+13）。转换公式：`nzst_time = utc_time + 12h`（夏令时期间 +13h）。

以下发件人/收件人自动跳过，不生成交互记录：

```yaml
skip_patterns:
  exact_match:
    - noreply@*
    - no-reply@*
    - newsletter@*
    - notifications@*
    - mailer-daemon@*
    - postmaster@*
  domain_match:
    - "*.noreply.github.com"
    - "mail.google.com"
    - "accounts.google.com"
  keyword_in_subject:
    - "unsubscribe"
    - "自动回复"
    - "out of office"
    - "auto-reply"
  header_check:
    - "List-Unsubscribe header 存在 → 判定为营销邮件"
    - "Precedence: bulk → 判定为群发邮件"
```

**自定义白名单**：用户可在 `config.yaml` 中添加 `always_include` 列表，强制保留特定发件人。

### 线程合并

同一 `thread_id` 的邮件合并为一次交互：
- `participants`：线程内所有参与者的并集
- `content_summary`：最新一封邮件的摘要
- `interaction_count`：线程内邮件数量
- `timestamp`：最新一封邮件的时间

---

## 数据源 2：Google Calendar 扫描

### 扫描范围

- 使用 Calendar API `events.list`
- 时间范围：`last_scan_time` 到 `now + 7 days`（含未来一周的已确认会议）
- 只扫描 `status: confirmed` 的事件

### 提取字段

| 字段 | 提取方式 |
|------|----------|
| title | `summary` 字段 |
| attendees | `attendees` 数组，提取 `displayName` + `email` |
| description | `description` 字段，截取前 500 字符 |
| start_time | `start.dateTime`，转 ISO 8601 |
| end_time | `end.dateTime` |
| duration_minutes | 计算得出 |
| location | `location` 字段（可能是实体地址或 Zoom/Meet 链接） |
| is_recurring | `recurringEventId` 是否存在 |
| response_status | 当前用户的 `responseStatus`（accepted/declined/tentative） |

### 过滤规则

```yaml
skip_calendar_events:
  - attendees 数量 = 0（私人提醒）
  - attendees 只有自己（个人日程）
  - title 包含 "Block"、"Focus Time"、"Lunch"
  - response_status = "declined"
```

---

## 数据源 3：会议纪要目录

### 监控机制

- 监控路径：`~/.openclaw/workspace/self-evolving-crm/meeting-notes/`
- 支持格式：`.md`、`.txt`
- 检测方式：比对文件修改时间（mtime）与 `last_scan_time`
- 新文件和已修改文件均触发处理

### 文件解析

使用 LLM 提取结构化信息：

```
Prompt: 从以下会议纪要中提取：
1. 会议主题
2. 参与人员（姓名、邮箱如有）
3. 关键讨论要点（不超过 5 条）
4. 待办事项（如有）
5. 会议日期（从文件名或正文推断）
```

**文件名约定**（可选）：`YYYY-MM-DD-主题.md` 便于自动提取日期。

---

## 数据源 4：手动输入

通过 CLI 命令快速记录交互：

```bash
openclaw log "和张三电话 30 分钟，讨论了合作方案"
openclaw log --contact "li.wei@company.com" --type meeting "项目启动会，确认了时间线"
```

LLM 解析自由文本，提取联系人、交互类型、内容摘要。

---

## 输出格式

每条扫描结果输出为标准化的 `interaction_record`：

```yaml
interaction_record:
  id: "ir_20260320_gmail_abc123"
  timestamp: "2026-03-20T14:30:00+12:00"
  type: "email"  # email | meeting | note | call | manual
  direction: "inbound"  # inbound | outbound | bilateral
  participants:
    - name: "张三"
      email: "zhangsan@company.com"
      role: "sender"  # sender | receiver | attendee
    - name: "用户自己"
      email: "user@gmail.com"
      role: "receiver"
  content_summary: "关于 Q2 合作提案的讨论，张三提出需要修改定价方案"
  source: "gmail"  # gmail | calendar | meeting_note | manual
  raw_reference:
    message_id: "abc123"
    thread_id: "thread_456"
  metadata:
    has_attachment: true
    interaction_count: 3  # 线程内邮件数
    duration_minutes: null  # 仅会议有值
```

---

## 增量扫描流程

```
1. 读取 last_scan.json 中的 last_scan_time 和 processed_ids.json 中的已处理 ID
2. 对每个数据源并行扫描：
   a. Gmail: query = "after:{last_scan_time_epoch}"
      → 过滤 skip_patterns
      → 过滤 processed_email_ids（避免重复）
      → 按 thread_id 合并
   b. Calendar: timeMin = last_scan_time
      → 过滤规则
   c. Meeting Notes: mtime > last_scan_time
      → LLM 解析
3. 所有结果写入下游 Agent 的输入（raw_interaction_records）
4. 更新状态文件:
   - last_scan.json → 更新 last_scan_time = now
   - processed_ids.json → 追加本次新 ID（滚动保留最近 30 天）
5. 触发下游 Agent 处理
```

### 状态文件结构

状态文件存储在 `~/.openclaw/workspace/self-evolving-crm/` 目录下：

**last_scan.json**：
```json
{
  "last_scan_time": "2026-03-20T10:00:00+12:00",
  "scan_stats": {
    "total_scans": 42,
    "last_scan_items": 7,
    "last_scan_duration_seconds": 12
  }
}
```

**processed_ids.json**：
```json
{
  "email_ids": ["msg_abc123", "msg_def456"],
  "note_files": [
    {"path": "~/.openclaw/workspace/self-evolving-crm/meeting-notes/2026-03-19-kickoff.md", "mtime": 1711234567}
  ]
}
```

---

## 错误处理

| 场景 | 处理方式 |
|------|----------|
| Gmail API 认证失败 | 记录错误日志，跳过 Gmail，继续扫描其他源 |
| Gmail API 限流（429） | 指数退避重试，最多 3 次，间隔 2s/4s/8s |
| Calendar API 失败 | 同上，独立于 Gmail 错误 |
| 会议纪要文件编码错误 | 尝试 UTF-8 → GBK → Latin-1，仍失败则跳过并记录 |
| LLM 解析返回异常格式 | 使用默认值填充，标记 `parse_quality: low` |
| 网络断开 | 终止本次扫描，不更新 last_scan_time，下次重试 |
| 单封邮件处理异常 | 跳过该邮件，继续处理其他邮件，记录失败 ID |

### 错误日志格式

```yaml
error_log:
  - timestamp: "2026-03-20T14:35:00+12:00"
    source: "gmail"
    error_type: "api_auth_failure"
    message: "Token expired, refresh failed"
    action_taken: "skipped_source"
    items_affected: 0
```

---

## 性能考量

- Gmail 单次最多拉取 100 封邮件（API 默认分页），超过则自动翻页
- Calendar 一次最多 250 个事件
- 会议纪要文件大小上限：500KB，超过截取前 500KB
- 全量扫描（首次运行）回溯 90 天
- 常规增量扫描预计 5-15 秒完成
