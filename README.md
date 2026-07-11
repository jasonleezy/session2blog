# Session2Blog

Turn your OpenClaw conversation history into clean, structured blog posts — with one slash command: `/s2b`.

No API key. No terminal setup. No copy-paste. The AI you're already talking to does the writing, using the model from your current OpenClaw session.

## What it does

You finish a coding / debugging / research session in OpenClaw. Type `/s2b`. The skill:

1. Extracts the dialogue from your session JSONL (filters out tool-call noise)
2. Auto-redacts sensitive data (API keys, real paths, emails, usernames)
3. Detects the right template (Tech Review / Learning Notes / Troubleshooting)
4. Rewrites the content in your chosen platform's viral style
5. Saves a Markdown file to `~/.openclaw/session2blog/articles/`

## Platform-specific styles

Same conversation, rewritten for each platform's audience:

| Flag | Platform | Style |
|------|----------|-------|
| `--platform wechat` | WeChat Official Account | Story-driven, emotional, hook-led |
| `--platform juejin` | Juejin | Hardcore, code-heavy, structured |
| `--platform csdn` | CSDN | Problem-first, step-by-step, SEO-friendly |
| `--platform zhihu` | Zhihu | Opinion-led, deep, dialectical |
| `--platform all` | All of the above | Generates 4 versions at once |
| `--platform none` | Generic (default) | Balanced tone |

## Install

```bash
# Option A: install script
bash install.sh

# Option B: manual
cp -r session2blog ~/.openclaw/skills/

# Restart your OpenClaw session, then type /s2b
```

Requires `python3` (comes with macOS). No external network calls for the free version.

## Usage

```
/s2b                          # current session, auto template, generic style
/s2b -n 3                     # 3rd session in the list
/s2b --session <id>           # specific session ID
/s2b --template tech-review   # force template
/s2b --platform wechat        # WeChat style output
/s2b --platform all           # all 4 platform styles at once
/s2b --list                   # list available sessions
```

## Privacy

Sensitive data is redacted **before** anything is written:
- API keys / tokens → `<REDACTED>`
- Absolute paths `/Users/xxx` → `<USER_HOME>/...`
- Emails / usernames / phones → placeholders

Your chats never leave your machine in the free version.

## Pro version

The free version generates local Markdown. **Session2Blog Pro** ($5, lifetime updates) adds:

- **One-click publish** to WeChat / Juejin / CSDN / Zhihu
- **Scheduled push** (cron integration)
- **Priority support**

👉 Get Pro: https://jasonlizy.gumroad.com/l/session2blog-pro

## License

MIT — do whatever you want, just don't blame me if it writes a bad blog post.
