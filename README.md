# slop-free

A Claude Code skill for AI-assisted pull requests to open-source projects you don't
maintain, so what lands in a maintainer's queue is a fix and not slop. It's the
checklist I wish I'd had before my first one.

I spent two months fixing bugs in about 25 projects with an AI coding agent. Some
PRs merged. Others were closed: as duplicates, as "low quality", for not following
a policy I hadn't read, or because the fix only made a test pass. Every rule in
here comes from one of those, and
[`lessons.md`](plugin/skills/slop-free/references/lessons.md) has the incident
behind each one, anonymized.

The short version:

- The human sees the diff and the exact text before every push, comment or PR.
- Follow each project's AI policy to the letter, including disclosure.
- Root cause or nothing, and a regression test shown failing without the fix.
- A check that never ran looks exactly like a check that passed.
- At most 2 open PRs per repo and 3 new ones a week. Look after the open ones first.

## Install

```bash
/plugin marketplace add Kjubikstronk/slop-free
/plugin install slop-free@slop-free
```

Or copy `plugin/skills/slop-free` into `~/.claude/skills/`.

## What's inside

| File | What it's for |
| --- | --- |
| `SKILL.md` | The rules, by phase: choosing a bug, the fix, verification, the PR, reviews and CI, closing |
| `references/verification-traps.md` | Ways a check looks green while being wrong |
| `references/templates.md` | PR description, review replies, claims, closes, nudges |
| `references/windows.md` | Toolchain traps on Windows |
| `references/lessons.md` | Every rule with the incident that taught it |
| `scripts/preflight.sh` | Read-only checks before you start: is anyone merging outside work, what the policy files say, who else is fixing it |
| `scripts/pr-sweep.sh` | Read-only sweep of your upstream PRs: inline threads, unresolved threads, closed PRs, label and review events, CI, and comments about your PR posted on other threads |

Both scripts need an authenticated [`gh`](https://cli.github.com/) and bash (Git
Bash on Windows). They only read:

```bash
bash plugin/skills/slop-free/scripts/preflight.sh owner/repo --issue 123 --file src/parse.js
bash plugin/skills/slop-free/scripts/pr-sweep.sh 2026-10-01T00:00:00Z
```

## Make it yours

The volume limits and the "show me before you post" rule are defaults. Put your own
in your CLAUDE.md and the skill follows them, for example:

```markdown
## Open source
- Up to 4 open PRs per repo, 5 new a week.
- You may push fixups to my PR branches without asking; still show me any comment first.
```

Project policies always win over both.

## How this was made

Written with Claude Code from the notes we kept while contributing. The incidents
are real. Names and projects are left out on purpose: the point is the mistake,
not who caught it.

## License

MIT
