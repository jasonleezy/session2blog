# Session2Blog 📝

把 OpenClaw 会话历史一键润色成博文（技术复盘 / 学习笔记 / 排障记录）。

## 一句话

你在 OpenClaw 里跟 AI 干完活，输一句 `/s2b`，它就把刚才的对话整理成一篇结构化博文，直接保存为 Markdown 文件。

**零配置**：不需要 API Key，不需要装 PATH，不需要开终端。模型用 OpenClaw 会话自带的，对话读本地的。

> 🔒 **数据流向说明（请看清边界）**
> - **免费版**：100% 本地处理。对话只在你机器上读取、润色、保存为 Markdown 文件，**不出本机**。
> - **Pro 版（可选付费升级）**：新增「掘金一键发草稿」功能。开启后，文章内容和你的掘金 Cookie **会发往掘金 API**（https://api.juejin.cn），这是该功能明确的、需你主动配置 Cookie 才会发生的远程调用，并非默认行为。
> - 本工具绝不会在未经你显式操作的情况下，把任何内容或凭证发送到第三方。

## 适用场景

| 场景 | 模板 | 效果 |
|------|------|------|
| 刚修好一个 bug | `troubleshooting` | 排障记录，下次踩坑直接翻 |
| 刚学会一个新工具 | `learning-notes` | 学习笔记，内化成自己的 |
| 刚做完一个技术决策 | `tech-review` | 技术复盘，沉淀团队经验 |

## 安装

把 `session2blog/` 目录复制到 OpenClaw 的 skills 目录下即可：

```bash
# 方式一：直接复制（推荐）
cp -r session2blog ~/.openclaw/skills/

# 方式二：用安装脚本
bash install.sh
```

安装后重启 OpenClaw 会话（或新开一个），`/s2b` 命令即可用。

## 使用

在 OpenClaw 会话中直接输入：

```
/s2b                          # 处理当前会话，自动选模板，通用风格
/s2b -n 3                     # 处理列表里第 3 个会话
/s2b --session <id>           # 用完整 session ID 指定
/s2b --template tech-review   # 指定模板：tech-review | learning-notes | troubleshooting | auto(默认)
/s2b --platform wechat        # 微信公众号风格（故事感、情绪、代入感）
/s2b --platform juejin        # 掘金风格（硬核、代码密集、体系化）
/s2b --platform csdn          # CSDN 风格（问题导向、步骤化、实用）
/s2b --platform zhihu         # 知乎风格（观点感、深度、辩证）
/s2b --platform all           # 一次生成 4 个平台版本（wechat/juejin/csdn/zhihu 各一）
/s2b --list                   # 列出所有可用会话（带序号、Agent、日期）
```

### 示例

```
你: /s2b

→ AI 提取当前会话对话
→ 自动匹配「技术复盘」模板
→ 生成博文并保存到 ~/.openclaw/session2blog/articles/
→ 告诉你文件路径
```

## 平台风格适配

同一段对话，可以输出不同平台的爆款文风格。指定 `--platform` 后，AI 会按对应平台的读者预期重写标题和正文结构。

| 平台 | 风格特征 | 标题示例 |
|------|----------|----------|
| `wechat` 微信公众号 | 故事感、情绪、场景代入、口语化 | 「我做了3个月数字产品，0销量之后终于想通了一件事」 |
| `juejin` 掘金 | 硬核、体系化、代码密集、带目录 | 「万字长文讲透 OpenClaw Skill 开发」 |
| `csdn` CSDN | 问题导向、步骤化、搜索友好 | 「OpenClaw 会话导出失败？【已解决】」 |
| `zhihu` 知乎 | 观点感、深度、辩证、分层论证 | 「如何评价用 AI 把对话变成博客这件事？」 |
| `none` 通用（默认） | 平衡调性，[模板] 标题结构 | 「[复盘] 从0到1做数字产品的踩坑」 |
| `all` 全平台 | 一次生成上述 4 个平台版本 | — |

文件命名规则：`YYYY-MM-DD-<模板>-<平台>-<slug>.md`

例如：`2026-07-11-tech-review-wechat-openclaw-product.md`

生成的博文**自动脱敏**，不会泄露：
- API Key / Access Token / Secret（自动替换为 `<REDACTED>`）
- 真实用户名、邮箱、手机号（替换为占位符）
- 绝对文件路径（如 `/Users/jasonlee/...` 替换为 `<USER_HOME>/...`）

发布前可自查：`grep -rn "sk-\|eyJ\|/Users/" ~/.openclaw/session2blog/articles/`

## 模板说明

### 技术复盘 (tech-review)
```
标题: [复盘] <核心问题描述>

1. 背景 — 当时在做什么
2. 踩坑过程 — 遇到了什么
3. 关键决策 — 怎么分析的
4. 最终方案 — 怎么解决的
5. 总结与教训 — 学到了什么
```

### 学习笔记 (learning-notes)
```
标题: [笔记] <主题>

1. 学习动机 — 为什么学
2. 核心概念 — 用自己的话解释
3. 实践过程 — 踩过的坑、跑过的代码
4. 心得体会 — 真正理解了什么
```

### 排障记录 (troubleshooting)
```
标题: [排障] <问题现象>

1. 问题现象 — 具体表现
2. 排查过程 — 怎么查的，用了什么工具
3. 根因分析 — 根本原因
4. 解决方案 — 具体怎么修的
5. 预防措施 — 下次怎么避免
```

## 配置

配置文件：`~/.openclaw/session2blog/config.yaml`（安装时自动生成，权限 600）

```yaml
default_template: auto      # auto | tech-review | learning-notes | troubleshooting
default_platform: none      # none | wechat | juejin | csdn | zhihu | all
language: zh-CN
author: ""
articles_dir: ~/.openclaw/session2blog/articles
```

> 免费版无需任何 Cookie 或 API Key，完全本地闭环。掘金发布所需的 Cookie 配置仅 Pro 版涉及，见下方「Pro 版」段。

## 目录结构

```
session2blog/
├── SKILL.md          # Skill 定义（/s2b 命令行为）
├── s2b.sh            # 内部实现：读 session JSONL → 脱敏 → 提取对话 → 输出
├── install.sh        # 安装脚本（复制到 ~/.openclaw/skills/）
├── README.md         # 本文件
└── gumroad-product-copy.md  # 产品页文案

~/.openclaw/session2blog/   # 运行时目录（自动创建）
├── config.yaml        # 配置文件（权限 600）
├── articles/          # 生成的博文
└── logs/
```

## 产品信息

- 定价: 免费（MIT 开源）
- 平台: OpenClaw Skill（需要 OpenClaw 环境）

---

## 🚀 Pro 版（付费，一次性 $5，终身更新）

免费版只生成本地 Markdown + 平台风格适配。**Pro 版额外支持：**

- ✅ **掘金一键发草稿**（需 Pro 版代码）：`/s2b --platform juejin --publish` 直接把文章送进你的掘金草稿箱（默认草稿，您审过后再手动公开）
- ✅ 两种模式：本地模型写文后发 / 先生成 .md 再发
- ✅ 优先支持

**获取 Pro：** https://jasonlizy.gumroad.com/l/session2blog-pro

> 路线图（已购用户免费更新）：微信公众号 / CSDN / 知乎发布、定时推送。

## 💬 支持 / 反馈

- **买了 Pro 有问题**：回复你的 Gumroad 收据邮件，或开 GitHub Issue（**请勿公开粘贴 Cookie / 账号凭证**）
- **功能建议 / Bug**：[GitHub Issues](https://github.com/jasonleezy/session2blog/issues)
- **免费版问题**：同上，欢迎提 Issue
