## Description: <br>
Session2Blog turns OpenClaw session history into structured Chinese Markdown blog posts for technical reviews, learning notes, and troubleshooting writeups. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[jasonleezy](https://clawhub.ai/user/jasonleezy) <br>

### License/Terms of Use: <br>
MIT-0 <br>


## Use Case: <br>
Developers and OpenClaw users use this skill to convert recent or selected session transcripts into reusable Chinese blog posts, technical retrospectives, learning notes, and troubleshooting records, with optional platform-specific style guidance. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: The skill reads selected local OpenClaw session transcripts, which may contain sensitive content. <br>
Mitigation: Review selected sessions and generated Markdown before sharing, and keep automatic redactions intact. <br>
Risk (Pro version only): Cookie-backed publishing can expose or misuse an account session if a Juejin cookie is mishandled. The free ClawHub version has no publishing and no cookie handling. <br>
Mitigation: Treat publishing cookies like passwords, store them only in the local config with restrictive permissions, and remove or rotate them when no longer needed. <br>
Risk (Pro version only): Remote publishing can send generated content outside the local environment. The free version is fully local. <br>
Mitigation: Use publishing only after confirming exactly what content will be sent, and review drafts in the target platform before public release. <br>


## Reference(s): <br>
- [ClawHub skill page](https://clawhub.ai/jasonleezy/skills/session2blog) <br>


## Skill Output: <br>
**Output Type(s):** [text, markdown, shell commands, configuration, guidance] <br>
**Output Format:** [Markdown articles and in-chat guidance with shell command examples] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [Generated articles are saved locally under the configured Session2Blog articles directory; platform style can target wechat, juejin, csdn, zhihu, none, or all.] <br>

## Skill Version(s): <br>
1.1.4 (source: server release metadata) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
