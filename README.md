# merge-worthy

A Claude Code skill for agent-assisted pull requests to open-source projects you
don't maintain. It's the checklist I wish I'd had before my first one.

I spent two months fixing bugs in about 25 projects with an AI coding agent. Some
PRs merged, including one into Node.js core. Others were closed: as duplicates, as
"low quality", for not following a policy I hadn't read, or because the fix only
made a test pass. Every rule in here comes from one of those, and
[`lessons.md`](plugin/skills/merge-worthy/references/lessons.md) has the incident
behind each one, anonymized.

The short version:

- The human sees the diff and the exact text before every push, comment or PR.
- Follow each project's AI policy to the letter, including disclosure.
- Root cause or nothing, and a regression test shown failing without the fix.
- A check that never ran looks exactly like a check that passed.
- At most 2 open PRs per repo and 3 new ones a week. Look after the open ones first.

## Install

```bash
/plugin marketplace add Kjubikstronk/merge-worthy
/plugin install merge-worthy@merge-worthy
```

Or copy `plugin/skills/merge-worthy` into `~/.claude/skills/`.

## What's inside

| File | What it's for |
| --- | --- |
| `SKILL.md` | The rules, by phase: choosing a bug, the fix, verification, the PR, reviews and CI, closing |
| `references/verification-traps.md` | Ways a check looks green while being wrong |
| `references/windows.md` | Toolchain traps on Windows |
| `references/lessons.md` | Every rule with the incident that taught it |
| `scripts/pr-sweep.sh` | Read-only sweep of your upstream PRs: inline threads, unresolved threads, closed PRs, label and review events, CI |

The sweep needs an authenticated [`gh`](https://cli.github.com/):

```bash
bash plugin/skills/merge-worthy/scripts/pr-sweep.sh 2026-10-01T00:00:00Z
```

## How this was made

Written with Claude Code from the notes we kept while contributing. The incidents
are real. Names and projects are left out on purpose: the point is the mistake,
not who caught it.

## License

MIT
