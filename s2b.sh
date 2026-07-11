#!/bin/bash
# Session2Blog — 把 OpenClaw 对话历史一键润色为博文
# Usage:
#   s2b                                   # 处理最新会话，自动选模板
#   s2b --list                            # 列出可用会话
#   s2b --session <id>                    # 指定会话
#   s2b --template tech-review|learning-notes|troubleshooting|auto
#   s2b --platform wechat|juejin|csdn|zhihu|none|all

set -euo pipefail

ARTICLES_DIR="${S2B_ARTICLES:-$HOME/.openclaw/session2blog/articles}"
CONFIG_FILE="${S2B_CONFIG:-$HOME/.openclaw/session2blog/config.yaml}"
SESSION_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/agents/${S2B_AGENT:-yuanbao}/sessions"
mkdir -p "$ARTICLES_DIR"

# === 参数解析 ===
SESSION_ID=""
TEMPLATE="auto"
PLATFORM="none"
MODE="generate"
PUBLISH="false"
PUBLISH_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session) SESSION_ID="${2:-}"; shift 2 ;;
    --template) TEMPLATE="${2:-auto}"; shift 2 ;;
    --platform) PLATFORM="${2:-none}"; shift 2 ;;
    --publish) PUBLISH="true"; shift ;;
    --file) PUBLISH_FILE="${2:-}"; shift 2 ;;
    --list) MODE="list"; shift ;;
    -n) SESSION_NUM="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: s2b [--list] [--session <id>] [--template auto|tech-review|learning-notes|troubleshooting] [--platform wechat|juejin|csdn|zhihu|none|all] [--publish] [--file <md-path>]"
      exit 0 ;;
    *) echo "未知参数: $1"; echo "用 s2b --help 查看用法"; exit 1 ;;
  esac
done

# 把所有逻辑交给 Python 处理（通过环境变量传参，避免 shell 引号地狱）
export S2B_MODE="$MODE"
export S2B_SESSION_ID="$SESSION_ID"
export S2B_SESSION_NUM="${SESSION_NUM:-}"
export S2B_TEMPLATE="$TEMPLATE"
export S2B_PLATFORM="$PLATFORM"
export S2B_SESSION_DIR="$SESSION_DIR"
export S2B_ARTICLES_DIR="$ARTICLES_DIR"
export S2B_CONFIG_FILE="$CONFIG_FILE"

python3 <<'PYEOF'
import os, glob, json, sys

session_dir = os.environ["S2B_SESSION_DIR"]
articles_dir = os.environ["S2B_ARTICLES_DIR"]
mode = os.environ.get("S2B_MODE", "generate")
session_id = os.environ.get("S2B_SESSION_ID", "")
template_type = os.environ.get("S2B_TEMPLATE", "auto")
platform_type = os.environ.get("S2B_PLATFORM", "none")

def load_meta(path):
    """读取会话第一行的元数据"""
    try:
        with open(path) as fh:
            first = json.loads(fh.readline())
            return first.get("id", "?"), first.get("timestamp", "")
    except Exception:
        return "?", ""

def count_messages(path):
    n = 0
    try:
        with open(path) as fh:
            for line in fh:
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                if d.get("type") == "message":
                    n += 1
    except Exception:
        pass
    return n

def redact(text):
    """脱敏：移除 appkey / token / 路径 / 邮箱 / 手机号等敏感信息"""
    import re
    # API Key / Token（常见格式）
    text = re.sub(r'(?i)(api[_-]?key|access[_-]?token|secret|token|bearer)\s*[:=]\s*\S+',
                  r'\1: <REDACTED>', text)
    # 长随机字符串（疑似 key/token，>=20位字母数字混合）
    text = re.sub(r'\b[A-Za-z0-9]{28,}\b', '<REDACTED_TOKEN>', text)
    # Gumroad / OpenAI 等 token 特征（mX... 开头）
    text = re.sub(r'\bm[A-Za-z0-9]{20,}\b', '<REDACTED_TOKEN>', text)
    # 绝对文件路径（/Users/... /home/... /root/...）
    text = re.sub(r'/Users/[^\s\"\'\`]+', '<USER_HOME>/...', text)
    text = re.sub(r'/home/[^\s\"\'\`]+', '<HOME>/...', text)
    text = re.sub(r'/root/[^\s\"\'\`]+', '<ROOT>/...', text)
    # 邮箱
    text = re.sub(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '<REDACTED_EMAIL>', text)
    # 手机号（中国大陆 11 位）
    text = re.sub(r'(?<![0-9])1[3-9]\d{9}(?![0-9])', '<REDACTED_PHONE>', text)
    # 本地 IP
    text = re.sub(r'\b127\.0\.0\.1\b', '<LOCALHOST>', text)
    text = re.sub(r'\b192\.168\.\d{1,3}\.\d{1,3}\b', '<LAN_IP>', text)
    text = re.sub(r'\b10\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', '<LAN_IP>', text)
    # 用户名提及（@xxx，非邮箱部分）
    text = re.sub(r'(?<![A-Za-z0-9._%+-])@[A-Za-z0-9_]{3,}(?![A-Za-z0-9._%+-])', '@<REDACTED_USER>', text)
    return text

def extract_dialogue(path):
    dialogue = []
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            if d.get("type") != "message":
                continue
            role = d.get("message", {}).get("role", "?")
            content = d.get("message", {}).get("content", [])
            texts = []
            for c in content:
                if isinstance(c, dict) and c.get("type") == "text":
                    texts.append(c.get("text", ""))
            text = " ".join(texts).strip()
            if text and role in ("user", "assistant"):
                text = redact(text)
                prefix = "🤖 " if role == "assistant" else "👤 "
                dialogue.append(f"{prefix}{text}")
    return dialogue

def agent_of(path):
    p = os.path.dirname(path)
    return os.path.basename(os.path.dirname(p))

# === LIST 模式 ===
if mode == "list":
    print("")
    print("╔══════════════════════════════════════════════════════════════════════════════╗")
    print("║              Session2Blog — 可用会话列表                                  ║")
    print("╚══════════════════════════════════════════════════════════════════════════════╝")
    print("")
    print(f"  {'#':<4} {'AGENT':<12} {'日期':<12} {'消息数':<8} {'SESSION ID'}")
    print(f"  {'-'*4} {'-'*12} {'-'*10} {'-'*8} {'-'*36}")
    for i, f in enumerate(files[:25], 1):
        name = os.path.basename(f).replace(".jsonl", "")
        _, ts = load_meta(f)
        date = ts[:10] if ts else "?"
        count = count_messages(f)
        agent = agent_of(f)
        mark = "  ← 最新" if i == 1 else ""
        print(f"  {i:<4} {agent:<12} {date:<12} {count:<8} {name}{mark}")
    print("")
    print("  用法:")
    print("    s2b              # 直接处理最新的会话 (上面 #1)")
    print("    s2b -n 3         # 处理列表里第 3 个会话")
    print("    s2b --session <SESSION_ID>   # 用完整 ID 指定")
    print("    s2b --template <模板>          # 指定模板, 可选值:")
    print("        auto           自动识别 (默认, 根据内容猜模板)")
    print("        tech-review    技术复盘 — 背景/踩坑/决策/方案/教训")
    print("        learning-notes 学习笔记 — 动机/概念/实践/心得")
    print("        troubleshooting 排障记录 — 现象/排查/根因/解决/预防")
    print("    示例: s2b -n 3 --template tech-review")
    print("")
    sys.exit(0)

# === GENERATE 模式 ===
# 确定目标会话
session_num = os.environ.get("S2B_SESSION_NUM", "")
try:
    session_num = int(session_num) if session_num else 0
except ValueError:
    session_num = 0

if session_id:
    target = os.path.join(session_dir, session_id + ".jsonl")
elif session_num and 1 <= session_num <= len(files):
    target = files[session_num - 1]
else:
    target = files[0] if files else None

if not target or not os.path.isfile(target):
    print("[错误] 找不到会话文件")
    print("用 s2b --list 查看可用会话")
    sys.exit(1)

sid, ts = load_meta(target)
session_date = ts[:10] if ts else "unknown"
dialogue = extract_dialogue(target)

if not dialogue:
    print("[错误] 会话中没有可用的对话文本")
    sys.exit(1)

target_agent = agent_of(target)

# 自动判断模板
all_text = " ".join(dialogue).lower()
detected = "tech-review"
if any(w in all_text for w in ["bug", "修复", "报错", "error", "失败", "排查", "故障", "崩溃"]):
    detected = "troubleshooting"
elif any(w in all_text for w in ["教程", "上手", "入门", "guide", "tutorial", "学习笔记", "怎么用"]):
    detected = "learning-notes"

if template_type == "auto":
    template_type = detected

templates = {
    "troubleshooting": {
        "name": "排障记录",
        "title_fmt": "[排障] <问题现象>",
        "structure": (
            "1. 问题现象 — 出了什么问题，具体表现是什么\n"
            "2. 排查过程 — 怎么一步步查的，用了什么工具/命令\n"
            "3. 根因分析 — 根本原因是什么，为什么会出现\n"
            "4. 解决方案 — 具体怎么修的，代码/配置要点\n"
            "5. 预防措施 — 下次怎么避免同样的问题"
        ),
    },
    "learning-notes": {
        "name": "学习笔记",
        "title_fmt": "[笔记] <主题>",
        "structure": (
            "1. 学习动机 — 为什么学这个东西，解决了什么痛点\n"
            "2. 核心概念 — 关键知识点，用自己的话解释清楚\n"
            "3. 实践过程 — 踩过的坑、跑过的代码、关键配置\n"
            "4. 心得体会 — 不是文档翻译，是自己真正理解了什么"
        ),
    },
    "tech-review": {
        "name": "技术复盘",
        "title_fmt": "[复盘] <核心问题描述>",
        "structure": (
            "1. 背景 — 当时在做什么，上下文是什么\n"
            "2. 踩坑过程 — 遇到了什么问题，试了什么方法\n"
            "3. 关键决策 — 怎么分析的，权衡了什么\n"
            "4. 最终方案 — 怎么解决的，代码/配置要点\n"
            "5. 总结与教训 — 学到了什么，下次怎么做"
        ),
    },
}

tmpl = templates.get(template_type, templates["tech-review"])

platform_styles = {
    "wechat": "微信公众号 — 故事感、情绪、代入感。标题用痛点/悬念/数字(例:『我踩了3个坑，终于搞懂了XX』)；开头场景代入；正文口语化像朋友聊天；结尾金句+引导关注；减少代码密度",
    "juejin": "掘金 — 硬核、体系化、代码密集。标题直给技术关键词(例:『万字长文讲透XX』)；开头前置摘要；正文分节带小标题、代码块密集、步骤可复现；结尾技术总结",
    "csdn": "CSDN — 实用主义、问题导向、步骤化。标题问题+解决方案(例:『XX报错怎么办？【已解决】』)；开头直接说现象；正文步骤1/2/3+完整代码+注意事项；搜索友好",
    "zhihu": "知乎 — 观点感、深度、辩证。标题问答/观点句式(例:『如何评价XX？』)；开头先亮核心观点；正文分层论证+案例+辩证；结尾收敛结论+开放讨论",
    "none": "通用风格 — 平衡调性，标题用 [模板类型] <核心问题> 结构，代码适量，专业但不堆砌",
    "all": "全平台 — 生成 wechat/juejin/csdn/zhihu 四个版本，各按对应风格输出",
}
platform_label = platform_styles.get(platform_type, platform_styles["none"])

dialogue_text = "\n".join(dialogue)

# 构建写作指令文本（打印给会话模型，由助手写文）
instruction_lines = []
instruction_lines.append(f"模板: {tmpl['name']}")
instruction_lines.append(f"标题格式: {tmpl['title_fmt']}")
instruction_lines.append(f"平台风格: {platform_label}")
instruction_lines.append("")
instruction_lines.append("请根据上述对话内容，按以下结构写一篇完整的博文(Markdown 格式)：")
instruction_lines.append("")
instruction_lines.append(tmpl["structure"])
instruction_lines.append("")
if platform_type == "all":
    instruction_lines.append("⚠️  --platform all：请生成 4 个文件，分别对应以下平台风格：")
    for p in ["wechat", "juejin", "csdn", "zhihu"]:
        instruction_lines.append(f"   - {p}: {platform_styles[p]}")
    instruction_lines.append(f"文件名: {session_date}-{template_type}-<平台>-<简短英文标题>.md")
else:
    instruction_lines.append(f"文件名: {session_date}-{template_type}-{platform_type}-<简短英文标题>.md")
instruction_lines.append(f"保存路径: {articles_dir}/")
instruction_lines.append("")
instruction_lines.append("要求:")
instruction_lines.append("  - 语言: 中文")
instruction_lines.append("  - 语气: 按平台风格调整（微信口语 / 掘金硬核 / CSDN 实用 / 知乎辩证 / 通用平衡）")
instruction_lines.append("  - 不要出现【AI生成】类标签")
instruction_lines.append("  - 该贴代码就贴代码，该贴配置就贴配置（微信平台可减少代码密度）")
instruction_lines.append("  - 标题必须符合指定平台的标题调性，从对话内容中提炼，不要用占位符")
instruction_lines.append("  - 敏感信息保护: 禁止出现 API Key/Token/真实路径/邮箱/用户名，保持脱敏状态")
instruction_text = "\n".join(instruction_lines)

# === 发布模式 ===
    else:
        print(f"[失败] 掘金发布出错: {resp}")
    sys.exit(0)

# === 非发布模式：打印写作指令（原行为） ===
print("")
print("╔══════════════════════════════════════════════════════════════╗")
print("║              Session2Blog — 博文生成器                      ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("")
print(f"  会话: {sid[:40]}")
print(f"  Agent: {target_agent}")
print(f"  时间: {session_date}")
print(f"  消息: {len(dialogue)} 条")
print(f"  模板: {tmpl['name']}  (自动检测: {detected})")
print(f"  平台: {platform_type}")
print("")
print("  " + "-"*50)
print(f"  对话内容（全文，共 {len(dialogue)} 条消息）：")
print("  " + "-"*50)
print("")
for msg in dialogue:
    print(msg)
print("")
print("  " + "-"*50)
print("")
print("╔══════════════════════════════════════════════════════════════╗")
print("║  🖊  写作指令                                                ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("")
print(instruction_text)
print("")
print("  " + "-"*50)
print("  现在请生成博文并保存到上述路径。")
print("  " + "-"*50)
PYEOF