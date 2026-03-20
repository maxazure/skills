# 联系人充实 — 详细规范

## 角色定义

联系人充实（Enrichment Agent）负责自动补全联系人的公司、职位、LinkedIn、社交资料等信息。采用瀑布式多源查询策略，优先使用免费和即时的数据源，逐步递进到外部 API。

**核心原则**：免费优先，逐级递进，标注来源，不覆盖用户手动输入的数据。

---

## 瀑布式充实策略

按优先级依次尝试三个数据源，每个阶段只补充前序阶段缺失的字段：

```
源 1: 邮件签名解析（免费、即时、最可靠）
  ↓ 缺失字段
源 2: 公司网站抓取（免费、需网络请求）
  ↓ 仍缺失字段
源 3: Apollo.io API（免费配额、最全面）
```

每个字段一旦被某个源填充，后续源不再覆盖（除非置信度更高）。

---

## 源 1：邮件签名解析

### 原理

从联系人发送的邮件正文底部提取签名块，解析其中的结构化信息。这是最可靠的信息源——签名是本人维护的，通常比第三方数据库更准确。

### 签名块定位

```
策略（按优先级）：
1. 检测 "--" 或 "—" 分隔线之后的内容
2. 检测 HTML 邮件中 class="signature" 的元素
3. 取邮件正文最后 10 行
4. 使用 LLM 判断签名块起始位置
```

### 提取字段

| 目标字段 | 提取方式 |
|----------|----------|
| job_title | 正则：常见职位关键词（CEO, CTO, Manager, 总监, 经理） + LLM 辅助 |
| company | 正则：公司名模式 + "at {Company}" + 域名反查 |
| phone | 正则：国际/国内电话号码模式，支持 +64, +86, +1 等 |
| address | 正则：含邮编/城市/街道的行 |
| website | 正则：URL 模式 |
| linkedin | 正则：`linkedin.com/in/xxx` 模式 |
| wechat | 正则："微信" 或 "WeChat" 后跟的 ID |

### 签名解析 Prompt

```
从以下邮件签名中提取结构化信息。如果某字段无法确定，返回 null。
注意：签名可能是中文、英文或混合的。

签名内容：
{signature_block}

返回 JSON：
{
  "name": "...",
  "job_title": "...",
  "company": "...",
  "phone": "...",
  "address": "...",
  "website": "...",
  "linkedin_url": "...",
  "wechat_id": "..."
}
```

### 多封邮件交叉验证

同一联系人的多封邮件签名可能不同（换工作、升职）：
- 取最新邮件的签名为主
- 如果最近 3 封邮件签名一致，置信度 = `high`
- 如果签名有变化，标记 `profile_change_detected`，保留历史记录

---

## 源 2：公司网站抓取

### 触发条件

源 1 完成后仍缺少以下任一字段：`company_size`、`industry`、`company_description`

### 流程

```
1. 从邮件地址提取域名：zhangsan@acme.com → acme.com
2. 跳过公共邮箱域名：gmail.com, outlook.com, qq.com, 163.com, hotmail.com 等
3. 访问 https://{domain}
4. 抓取页面 meta 信息：
   - <title> 标签
   - <meta name="description">
   - og:title, og:description
5. 尝试访问 /about, /about-us, /关于我们 页面
6. 使用 LLM 从页面内容提取：
   - company_name: 公司全称
   - industry: 行业分类
   - company_size: 员工规模（如可推断）
   - company_description: 一句话描述（50字以内）
   - location: 公司总部地址
```

### 限制与礼貌策略

- 每个域名最多访问 3 个页面
- 请求间隔 >= 2 秒
- 遵守 robots.txt
- User-Agent 设置为标准浏览器 UA
- 缓存结果 30 天（同域名下多个联系人共享公司信息）

---

## 源 3：Apollo.io API

### 触发条件

源 1 + 源 2 完成后仍缺少以下任一字段：`linkedin_url`、`job_title`、`company`

### API 调用

```
POST https://api.apollo.io/v1/people/match
Headers:
  Api-Key: {APOLLO_API_KEY}
  Content-Type: application/json
Body:
  {
    "email": "zhangsan@acme.com",
    "first_name": "San",        // 可选，提高匹配率
    "last_name": "Zhang",       // 可选
    "organization_name": "Acme" // 可选，从源 1/2 获得
  }
```

### 免费配额管理

- Apollo.io 免费版：每月 10,000 次 people enrichment
- 策略：优先对高价值联系人使用（有多次互动的 > 单次互动的）
- 追踪剩余配额，低于 500 次时发出警告
- 每次调用前检查本月已用次数

### 提取字段

| Apollo 字段 | 映射到 |
|-------------|--------|
| linkedin_url | linkedin_url |
| title | job_title |
| organization.name | company |
| organization.estimated_num_employees | company_size |
| organization.industry | industry |
| city, state, country | location |
| twitter_url | twitter_url |
| organization.website_url | company_website |

---

## 实体解析（去重合并）

### 问题场景

同一个人可能出现多种形式：
- 不同邮箱：zhangsan@acme.com 和 san.zhang@gmail.com
- 不同名字：张三、Zhang San、S. Zhang、San
- 不同来源：Gmail 联系人 vs 日历参与者

### 四层匹配策略

```yaml
tier_1_exact_email:
  condition: "email_a == email_b"
  confidence: 1.0
  action: "auto_merge"

tier_2_domain_name:
  condition: "email_domain 相同 AND name_similarity > 0.8"
  confidence: 0.95
  action: "auto_merge"
  name_similarity: "Jaro-Winkler 算法"

tier_3_company_name:
  condition: "company 相同 AND name_similarity > 0.7"
  confidence: 0.8
  action: "suggest_merge"  # 需用户确认

tier_4_fuzzy_name:
  condition: "name_similarity > 0.85 AND 至少一个其他字段匹配（phone/linkedin/company）"
  confidence: 0.7
  action: "suggest_merge"
```

### 合并决策

| 置信度 | 动作 |
|--------|------|
| > 0.9 | 自动合并，记录合并日志 |
| 0.7 - 0.9 | 生成合并建议，等待用户确认 |
| < 0.7 | 保持独立记录 |

### 合并规则

当两条记录合并时：
- `email`：保留所有邮箱，标记主邮箱（互动最多的那个）
- `name`：优先保留用户手动输入的 > 签名中的 > API 返回的
- 其他字段：有值的覆盖空值；两者都有值时保留置信度更高的
- 合并后保留完整的合并历史：`merged_from: [contact_id_a, contact_id_b]`

---

## 中文姓名处理

### 常见变体

| 原始 | 可能的变体 |
|------|-----------|
| 张三 | Zhang San, San Zhang, S. Zhang, 三张（误序） |
| 李小明 | Li Xiaoming, Xiaoming Li, X. Li, XM Li |
| 王建国 | Wang Jianguo, Jianguo Wang, J. Wang, JG Wang |

### 匹配策略

```
1. 中文 → 拼音转换（使用 pypinyin 或等效库）
2. 忽略声调
3. 姓在前/在后均匹配：Zhang San ≈ San Zhang
4. 缩写匹配：S. Zhang ≈ San Zhang（首字母 + 姓氏完整匹配）
5. 中英混合：张 San → 提取姓氏"张"的拼音"Zhang"与"San"组合
```

---

## 输出格式

充实后的联系人档案：

```yaml
enriched_contact:
  id: "contact_zhangsan_001"
  primary_email: "zhangsan@acme.com"
  all_emails:
    - "zhangsan@acme.com"
    - "san.zhang@gmail.com"
  name:
    display: "张三"
    pinyin: "Zhang San"
    source: "email_signature"
  job_title:
    value: "技术总监"
    source: "email_signature"
    confidence: "high"
    last_updated: "2026-03-15"
  company:
    name: "Acme 科技有限公司"
    size: "50-200"
    industry: "软件开发"
    website: "https://acme.com"
    source: "website_scrape"
  linkedin_url:
    value: "https://linkedin.com/in/zhangsan"
    source: "apollo_api"
  phone:
    value: "+64 21 123 4567"
    source: "email_signature"
  location:
    value: "Auckland, New Zealand"
    source: "apollo_api"
  wechat_id:
    value: "zhangsan_wx"
    source: "email_signature"
  enrichment_history:
    - date: "2026-03-10"
      sources_tried: ["email_signature", "website_scrape"]
      fields_added: ["job_title", "company", "phone"]
    - date: "2026-03-15"
      sources_tried: ["apollo_api"]
      fields_added: ["linkedin_url", "location"]
  merged_from: []
  enrichment_status: "complete"  # complete | partial | pending
  missing_fields: []
```

---

## 充实触发时机

| 触发条件 | 行为 |
|----------|------|
| 新联系人首次出现 | 立即执行全瀑布流程 |
| 现有联系人互动 | 检查签名是否有更新（职位/公司变动） |
| 手动请求 | `openclaw enrich zhangsan@acme.com` |
| 定期刷新 | 每月对所有活跃联系人重新执行源 1 |
| 合并触发 | 两条记录合并后重新评估字段完整度 |

---

## 配额与成本控制

```yaml
enrichment_limits:
  website_scrape:
    max_per_day: 100
    cache_days: 30
  apollo_api:
    monthly_quota: 10000
    used_this_month: 0
    reserve_threshold: 500  # 低于此值发出警告
    priority_rule: "仅对互动次数 >= 2 的联系人使用"
  llm_calls:
    per_contact: 3  # 签名解析 + 网页提取 + 纪要解析
```
