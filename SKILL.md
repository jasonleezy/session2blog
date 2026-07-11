---
name: session2blog
description: "把 OpenClaw 会话历史一键润色成博文（技术复盘/学习笔记/排障记录），自动保存为 Markdown 文件。在会话中输入 /s2b 即可触发。"
metadata:
  {
    "openclaw":
      {
        "emoji": "📝",
        "requires": { "bins": ["python3"] },
        "install": [],
      },
  }
---

# Session2Blog (s2b)

把当前或指定的 OpenClaw 会话对话历史，按模板润色成一篇结构化博文，保存为 Markdown 文件到本地。

## Trigger

用户在会话中说以下任一情况时触发本 skill：
- `/s2b` 或 `/session2blog`
- "把刚才的对话整理成博文"
- "帮我写篇复盘/笔记/排障文章"
- "把这个会话导出成博客"

## 用法

```
/s2b                          # 处理当前会话（或最近一次会话），默认通用风格
/s2b -n 3                     # 处理列表里第 3 个会话
/s2b --session <id>           # 用完整 session ID 指定
/s2b --template tech-review   # 指定模板：tech-review | learning-notes | troubleshooting | auto(默认)
/s2b --platform wechat        # 指定平台风格：wechat | juejin | csdn | zhihu | none(默认) | all(全平台各一版)
/s2b --platform all --template tech-review   # 一次生成微信公众号+掘金+CSDN+知乎 4 个版本
```

## 工作流程

当用户触发时，按以下步骤执行：

### Step 1: 调用内部脚本提取对话

运行附带脚本 `s2b.sh` 提取对话文本并打印到会话中：

```bash
bash <skill_dir>/s2b.sh --list          # 先列出可用会话（带序号）
bash <skill_dir>/s2b.sh -n <N> --template <T>   # 提取指定会话对话
```

脚本会输出：
- 会话基本信息（ID / Agent / 时间 / 消息数）
- 自动检测的模板类型
- **完整对话文本**（已过滤工具调用等噪声）
- 写作指令（模板结构 + 保存路径）

### Step 2: AI 润色生成博文

根据脚本输出的对话文本和模板结构，写一篇完整的博文（Markdown 格式）。

**平台风格适配（关键）：**

生成博文时，必须根据用户指定的 `--platform` 参数套用对应平台的爆款文风格。
不同平台的读者预期、标题习惯、正文结构差异很大，不能只改个标题就完事。

`--platform` 可选值：`wechat`(微信公众号) | `juejin`(掘金) | `csdn`(CSDN) | `zhihu`(知乎) | `none`(默认，通用风格)

#### 各平台爆款文风格定义

**微信公众号 (wechat)** — 故事感、情绪、代入感
- **标题**：痛点/悬念/数字驱动。例：「我踩了3个坑，终于搞懂了XX」「做了5年开发，我才明白XX」
- **开头**：场景代入，用「你有没有遇到过…」拉近距离
- **正文**：口语化，像朋友聊天，有情绪起伏，适当加粗金句
- **结尾**：总结一句扎心的话 + 引导「关注我，持续分享」
- **禁忌**：不要太硬核堆代码，读者是泛技术人群

**掘金 (juejin)** — 硬核、体系化、代码密集
- **标题**：直给技术关键词 + 价值感。例：「万字长文讲透XX」「从0到1实现一个XX」
- **开头**：前置摘要（本文讲什么、你能学到什么）
- **正文**：分节清晰带小标题，代码块密集，步骤可复现，可用目录锚点
- **结尾**：技术总结 + 延伸思考
- **特征**：专业术语直接用，读者是资深开发者

**CSDN (csdn)** — 实用主义、问题导向、步骤化
- **标题**：问题+解决方案。例：「XX报错怎么办？【已解决】」「手把手教你XX」
- **开头**：直接说问题现象
- **正文**：步骤1/2/3，完整可复制代码，注意事项单列
- **结尾**：验证结果 + 常见坑提示
- **特征**：搜索友好，解决具体问题，不要铺垫

**知乎 (zhihu)** — 观点感、深度、辩证
- **标题**：问答/观点句式。例：「如何评价XX？」「做XX是一种什么体验？」
- **开头**：先亮核心观点（我的看法是…）
- **正文**：分层论证，引案例/数据/他人观点，承认局限性，辩证看待
- **结尾**：收敛结论 + 开放讨论引导
- **特征**：有个人见解，不是纯教程，要体现思考深度

**通用 (none/默认)** — 平衡风格，适合先生成再手动改
- 标题：`[模板类型] <核心问题>` 结构
- 正文：结构清晰，代码适量，专业但不堆砌

**模板结构（内容骨架，不随平台变）：**

- **技术复盘** `[复盘] <核心问题>`
  1. 背景 — 当时在做什么
  2. 踩坑过程 — 遇到了什么问题
  3. 关键决策 — 怎么分析的，权衡了什么
  4. 最终方案 — 怎么解决的，代码/配置要点
  5. 总结与教训 — 学到了什么

- **学习笔记** `[笔记] <主题>`
  1. 学习动机 — 为什么学
  2. 核心概念 — 用自己的话解释
  3. 实践过程 — 踩过的坑、跑过的代码
  4. 心得体会 — 真正理解了什么

- **排障记录** `[排障] <问题现象>`
  1. 问题现象 — 具体表现
  2. 排查过程 — 怎么查的，用了什么工具
  3. 根因分析 — 根本原因
  4. 解决方案 — 具体怎么修的
  5. 预防措施 — 下次怎么避免

**写作要求：**
- 语言：中文
- 语气：按平台风格调整（微信口语 / 掘金硬核 / CSDN 实用 / 知乎辩证）
- 不要出现【AI生成】类标签
- 该贴代码就贴代码，该贴配置就贴配置（微信平台可减少代码密度）
- 标题从对话内容中提炼，不要用占位符，且必须符合指定平台的标题调性
- **敏感信息保护（强制）**：
  - 博文中**禁止出现**任何 API Key、Access Token、Secret、appkey 等凭证
  - **禁止出现**真实用户名、邮箱、手机号、真实全文件路径（如 `/Users/xxx/...`）
  - 如果对话中涉及上述内容，`s2b.sh` 已自动脱敏为 `<REDACTED>` / `<USER_HOME>/...` 等占位符，请**保持脱敏状态**，不要还原
  - 如需引用路径，用模糊化写法（如 `~/.openclaw/...` 或 `<项目目录>/...`）
  - 发布前自查：grep 一遍生成的 .md，确认无 `sk-`、无 `eyJ`、无真实 `@用户名`、无 `/Users/` 绝对路径

### Step 3: 保存文件

保存到 `~/openclaw/session2blog/articles/`（或 config 指定的路径），文件名规则：

```
YYYY-MM-DD-<模板名>-<平台>-<简短英文slug>.md
```

例如：`2026-07-11-tech-review-wechat-session2blog-pivot.md`

同时支持一次生成多平台版本：若用户指定 `--platform all`，则生成 4 个文件（wechat/juejin/csdn/zhihu 各一），共用同一对话内容但风格不同。

用 `write` 工具直接写出文件，并在会话里告知用户文件路径。

## 配置

配置文件：`~/.openclaw/session2blog/config.yaml`（安装时自动生成，权限 600）

```yaml
default_template: auto
language: zh-CN
author: ""
default_platform: none      # none | wechat | juejin | csdn | zhihu | all
articles_dir: ~/.openclaw/session2blog/articles

# 发布平台 Cookie（Pro 版，仅本地，不随包发出）
# 获取: 浏览器登录平台 → 开发者工具 → 复制 Cookie 整串
# 例: juejin_cookie: "sessionid=xxx; sid_tt=yyy; ..."
juejin_cookie:
```

> ⚠️ Cookie 等同登录态，勿分享、勿入仓库。本 skill 只在本机读取并仅发往对应平台 API。

## 文件结构

```
session2blog/
├── SKILL.md          # 本文件
├── s2b.sh            # 内部实现：读 session JSONL → 提取对话 → 输出
├── install.sh        # 安装脚本（复制到 ~/.openclaw/skills/ 或 ~/.local/bin）
├── README.md         # 用户文档
└── gumroad-product-copy.md  # 产品页文案
```

## 依赖

- `python3`（macOS 自带）
- 不需要 API Key —— 直接使用 OpenClaw 会话自带的模型

## 升级到 Pro 版（一键发布 + 定时推送）

免费版生成本地 Markdown 文件。想要以下功能，升级 Pro 版（$5 一次购买，终身更新）：

- **一键发布**到微信公众号 / 掘金 / CSDN / 知乎（无需手动复制）
- **定时自动推送**：配置 cron 后每天自动检查近期对话并生成博文
- **优先支持**

👉 获取 Pro 版：https://jasonlizy.gumroad.com/l/session2blog-pro
👉 开源免费版（GitHub）：https://github.com/jasonleezy/session2blog

（Pro 版包含本免费版的全部功能，并额外支持多平台直接发布。）
