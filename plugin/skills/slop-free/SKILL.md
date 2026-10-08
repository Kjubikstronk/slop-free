---
name: slop-free
description: Guides agent-assisted contributions to open-source repos the user doesn't maintain, from picking a bug to closing the PR, so the PR gets merged instead of closed as a duplicate, low quality or against policy. Use whenever the user wants to fix an issue in someone else's GitHub repo, asks whether a repo or issue is worth contributing to, wants to open, update or describe an upstream pull request, needs to answer a maintainer's or a review bot's comments (CodeRabbit, Copilot, Greptile, cubic), has a failing CI check or merge conflict on their PR, or asks to check their open PRs for replies. Also use for "first open source contribution" and "good first issue" requests. Not for repos the user maintains.
---

# slop-free

A closed PR costs the contributor more than no PR: maintainers remember names, and
an agent-assisted PR that wastes their time makes them less willing to take the next
outside contribution, from anyone. The aim here is fewer PRs that each deserve to
merge. Every rule below was learned by getting it wrong once;
`references/lessons.md` has the incident behind each.

## Start here

Work out what the user is asking for and jump in at the right place. Earlier
phases still apply if they were skipped: before writing a PR for a fix nobody
checked for duplicates, run the duplicate check.

| The user wants to... | Go to |
| --- | --- |
| find something to work on, or judge a repo or issue | 1, then `scripts/preflight.sh` |
| fix a specific issue | 1 (quickly), then 2 and 3 |
| open a PR or write its description | 3 if not done, then 4 |
| answer review comments, bot comments, red CI, a conflict | 5 |
| know whether anything needs them on their PRs | `scripts/pr-sweep.sh`, then 5 |
| know whether to close, nudge or wait | 6 |

## Defaults the user can change

These are defaults, not laws. If the user has set their own (in CLAUDE.md, a memory
file, or earlier in the conversation), follow theirs and say which you're using.

- **Approval before public actions.** Show the user the exact diff or text before
  anything that leaves the machine: opening a PR, pushing, commenting, replying,
  resolving a thread, closing. Approval covers that one action. This is the default
  most worth keeping, because the PR goes out under the user's name and they have to
  be able to explain every line when a maintainer asks.
- **Volume:** at most 2 open PRs per repo, 3 new PRs a week, and no new PRs while 15
  or more are open. Past that, maintenance quality drops and maintainers notice the
  pattern. Looking after open PRs comes before opening new ones.

Two things don't change whatever the defaults say: a project's own AI policy wins
(see below), and nothing gets published that the user hasn't seen if the project
requires the contributor's own words.

## Project policy comes first

Read CONTRIBUTING, any AGENTS.md or AI policy, and the PR template before
investigating, not after. `scripts/preflight.sh` prints the lines that usually
matter. Then do exactly what they say:

- Declines AI-assisted or agent-written contributions: stop and tell the user.
- Requires disclosure: do it in the form asked (a label, a checkbox, a trailer, a
  line in the body). If you can't apply a label yourself, say so in the PR.
- Requires the contributor's own words: the user writes the description and
  replies. You can supply facts and fix code formatting, nothing more.
- Requires an issue first, a CLA, a DCO sign-off, a changeset or changelog entry:
  handle it before the first push, because those block merging later.
- Bars PRs opened by tools: prepare the branch and let the user open it.

Policies aimed at agents exist because maintainers got burned. Following them
honestly is what keeps the door open.

## 1. Choosing the bug

- **Is anyone merging outside work?** A merge in the last two weeks, human replies
  on outside PRs, and several distinct outside authors merged recently. Lots of open
  issues with few outside authors merged means closed in practice.
- **Is it already being fixed?** Search open AND closed PRs and issues, the user's
  own included. Search by the file and function you'd change, not just the issue's
  words: a competing PR often never mentions the issue. `preflight.sh --issue N
  --file PATH` does both.
- **Is it still broken?** Reproduce on current main or the latest release. Many open
  bugs are already fixed.
- **Is it wanted?** An accepting-PRs label, a maintainer asking for it, or a kind of
  fix the repo demonstrably merges. Otherwise ask on the issue first. "Approved"
  means wanted, not small.
- **Is the code staying put?** Skip code that's being moved or rewritten.
- **Will it survive one read?** Prefer a narrow, demonstrable wrong output over
  retuning a heuristic. If the diff needs a paragraph of defence, don't open it.
- **Claim by exposure.** A fresh issue on a busy repo: claim it before starting. An
  old, quiet one: just fix it. Release a claim you stop working on.

## 2. The fix

- Trace every caller to the root cause. If a change only makes the test pass, say
  so to the user and stop: symptom patches are the PRs that get closed with "the
  solution isn't correct".
- Smallest diff in the repo's own style: reuse its helpers, copy the idiom of its
  recently merged PRs, split work the way it splits its own. One bug per PR.
- Never edit an existing test expectation to make the change pass. If one is
  genuinely wrong, say so in the PR and have the user verify it.
- Keep only checks that can fail. A guard that only exists to please the type
  checker is dead code.
- Match the file's comment density. The why goes in the commit message and PR.
- Porting from a reference implementation: don't port its bugs, and say what you
  left out.
- Keep local workarounds and lockfile churn out of commits.

## 3. Verification

- Run the relevant suite on the untouched tree first and keep the failing set, so
  you can tell your failures from pre-existing ones.
- Add a regression test. Revert the fix, watch it fail, restore it, watch it pass.
  A test that passes both ways proves nothing.
- Assert on the produced value, never on "nothing threw".
- Run the repo's formatter, linter and typecheck too. Reinstall dependencies after
  rebasing onto a newer upstream.
- If their CI runs Windows (`preflight.sh` checks), think about paths and line
  endings; `references/windows.md` has the usual traps.
- Test the claim in the PR you're least sure of. Say in the PR what you couldn't run.
- Before calling anything green, read `references/verification-traps.md`. A check
  that never ran looks exactly like a check that passed.

## 4. Writing the PR

- Follow the template and title convention exactly.
- Read three recently merged PRs and match their length and tone.
- What broke, why, what changed, how it's tested, what you left alone. Never walk
  through the diff line by line; the maintainer can read it.
- Plain and specific: no headers on a few lines, one table at most, no filler.
  Cut the first draft by half.
- A real-world motivation only if it's the user's real one.
- Disclose AI use in the project's form, once. Leave out tool footers and
  trailers the project didn't ask for: they read as advertising, not disclosure.
- `references/templates.md` has a skeleton and an example.

## 5. After opening

- **Every review comment gets an answer, bots included**: fix it, or give the reason
  you won't, then resolve the thread. One reply per thread, never a batch summary.
  Templates in `references/templates.md`.
- Answer a wrong suggestion with a concrete counterexample, not an opinion.
- Don't edit a reply someone has already answered. Put the change in the next one.
- If an AI review bot answers a reply by saving it as a repo-wide "learning"
  credited to the maintainers, and the user isn't one, correct it in one line in
  that thread. Only once it has happened: a pre-emptive note is noise.
- **Red CI: is it ours or flaky?** Decide before touching code. Compare the same job
  on main, read the failing step, check the project's flaky-test reports. A
  first-time contributor's CI may wait on a maintainer, and forks can't re-run
  upstream jobs.
- **Conflicts:** resolve them the way the branch is already maintained. Where
  force-push is forbidden, merge main in with a new commit.
- **A competing PR:** one factual comment so the maintainer sees both. If theirs
  merges, close the user's with one line.
- **Checking for replies:** run `scripts/pr-sweep.sh [SINCE]`. It covers inline
  threads, unresolved threads, closed PRs, label/assign/review events, conflicts, CI,
  and comments about the PR posted somewhere else: on a competing PR, on the issue,
  or anywhere that @-mentions the user. Feedback often lands there. Notification
  email is worth a look too; the web list truncates.

## 6. Closing

- A maintainer closes it or says close: close politely, no arguing, no reopening.
- No maintainer reply in 4+ weeks and marked stale or conflicting: suggest closing
  to the user.
- One nudge per repo covering sibling PRs, then wait two weeks.
- Close the user's duplicates and superseded PRs with a short neutral note.

## Scripts

Both are read-only and need an authenticated `gh` and bash (Git Bash on Windows).

- `scripts/preflight.sh OWNER/REPO [--issue N] [--file PATH]...`: merge activity
  and outside authors, policy lines, the user's PR load against the limits, PRs
  and claims on the issue, PRs touching the same files, Windows CI.
- `scripts/pr-sweep.sh [SINCE]`: everything on the user's open and recently closed
  upstream PRs that might need them. SINCE is an ISO timestamp, default 3 days ago.

The scripts and examples are GitHub-specific; the rules apply on any forge.

## References

- `references/verification-traps.md`: ways a check looks green while being wrong.
- `references/templates.md`: PR description, review replies, claims, closes, nudges.
- `references/windows.md`: toolchain traps on Windows.
- `references/lessons.md`: every rule with the incident that taught it.
