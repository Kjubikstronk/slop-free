---
name: merge-worthy
description: Discipline for agent-assisted pull requests to open-source projects you don't maintain, from picking the bug to closing the PR. Use when choosing an upstream bug to fix, before opening, pushing to or commenting on an upstream PR, when answering review or bot comments, when upstream CI goes red, or when sweeping your open PRs for replies. Not for repos you maintain.
---

# merge-worthy

A closed PR costs more than no PR. Maintainers remember names, and every
agent-assisted PR that wastes their time makes them less willing to take the next
outside contribution. Everything below was learned by getting it wrong at least once.
`references/lessons.md` has the incident behind each rule.

## Hard rules

1. **The human sees the diff and the exact text before every public action**:
   opening a PR, pushing to it, commenting, replying, resolving a thread, closing.
   They must be able to explain every line if a maintainer asks. Approval for one
   action is not approval for the next one.
2. **Follow the project's AI policy to the letter.** Disclose in the form it asks
   for (template checkbox, trailer, PR-body line). Where it wants the contributor's
   own words, the human writes them and the agent only formats code spans. Where it
   declines agent-assisted work, don't contribute there.
3. **Cap the volume.** At most 2 open PRs per repo, 3 new PRs a week, and none at
   all while 15 or more are open. Looking after open PRs comes before opening new
   ones. Tune the numbers, keep the idea.
4. **Root cause or nothing.** If a change only makes the test pass, say so and stop.
5. **Never edit an existing test expectation to make your change pass.** If one is
   genuinely wrong, call it out in the PR and have the human verify it.

## 1. Choosing the bug

- Maintainers are active: a merge in the last two weeks and human replies on
  outside PRs. Count distinct outside authors merged in the last two months. Lots
  of issues and few outside authors means closed in practice.
- Read CONTRIBUTING, the PR template and any AI policy before investigating.
  Issue-first repos: open the issue and wait. Frozen repos: skip.
- Search open AND closed PRs and issues for the same bug, your own included.
  Search by the file and function you'd change too, not only the issue's words: a
  competing PR often doesn't mention the issue at all.
- Check the code isn't about to be moved or rewritten.
- Reproduce on current main or the latest release first. A lot of open bugs are
  already fixed.
- Make sure the change is wanted: an accepting-PRs label, a maintainer asking for
  it, or a kind of fix the repo demonstrably merges. Otherwise ask on the issue.
  "Approved" means wanted, not small and not still broken.
- Prefer a narrow, demonstrable wrong output over retuning a heuristic.
- One-read test: would a competent maintainer trust this diff after reading it
  once? If it needs a paragraph of defence, don't open it.
- Claim by exposure. A fresh issue on a busy repo: claim it before you start. An
  old, quiet one: just fix it. Release any claim you stop working on.

## 2. The fix

- Trace every caller to the root cause. One visible bug can be several defects on
  one path.
- Smallest diff, in the repo's own style. Reuse its helpers, copy the idiom of its
  recently merged PRs, and split work the way the repo splits its own. One bug per PR.
- Keep only checks that can fail. A guard that exists to please the type checker
  is dead code, so cast instead.
- Match the file's comment density. The why goes in the commit message and the PR.
- Porting from a reference implementation: don't port its bugs. Say what you left
  out and offer to match it if asked.
- Keep local workarounds and lockfile churn out of commits.
- Check CLA, DCO sign-off and commit-message format at the first commit, not when
  the PR is blocked on them.

## 3. Verification

- Run the relevant suite on the untouched tree first. Compare the failing set, not
  the count.
- Add a regression test and show it failing without the fix and passing with it.
  Revert the fix and rerun every time: a test that passes both ways is a control,
  not a regression test.
- Assert on the produced value, never on "nothing threw".
- Run the repo's own formatter, linter and typecheck, not just the tests. Reinstall
  dependencies after rebasing onto a newer upstream.
- If their CI runs Windows, think about paths and CRLF.
- Test the sentence in the PR you're least sure of. If something can't run
  locally, say so in the PR.
- Before trusting any green result, go through `references/verification-traps.md`.
  A check that never ran looks exactly like a check that passed.

## 4. Writing the PR

- Follow the template and title convention exactly: issue link, changeset,
  changelog entry.
- Read three recently merged PRs and match their length and tone.
- Say what broke, why, what changed, how it's tested, and what you didn't fix.
  Never walk through the diff line by line.
- Plain and specific. No headers on a few lines of content, one table at most, no
  filler, no closing flourish. Cut the first draft by half.
- Give a real-world motivation only if it's the real one.
- Put the disclosure where the project asks for it. Where drafted comments are
  allowed with a disclaimer, the disclaimer is the first line.
- Where the project bars PRs opened by tools, the human opens it from the compare link.

## 5. After opening

- Every review comment, bots included, gets fixed or answered with a reason, then
  the thread resolved. One reply per thread, never a batch summary.
- Answer a wrong suggestion with a concrete counterexample, not an opinion.
- Don't edit a reply someone has already answered. Put the change in the next one.
- AI review bots may save your reply as a repo-wide rule credited to "maintainers".
  If you aren't one, say so in the thread.
- Red CI: decide whether it's yours or flaky before anything else. Compare the same
  job on main, read the failing step, check the project's flaky-test reports. A
  first-time contributor's CI may wait on a maintainer, and forks can't re-run
  upstream jobs.
- Conflicts: resolve them the way the branch is already maintained. Where
  force-push is forbidden, merge main in with a new commit.
- A competing PR appears: one factual comment so the maintainer sees both. If
  theirs merges, close yours with one line.
- Sweep every channel before saying "nothing new". `scripts/pr-sweep.sh` covers
  inline threads, unresolved threads, closed PRs, label/assign/review events and
  mergeability. Check notification email as well, because the web list truncates.
- Disable Actions on your forks. Their "no jobs were run" mails bury real replies.

## 6. Closing

- A maintainer closes it or says close: close politely. No arguing, no reopening
  as a new PR.
- No maintainer reply for 4+ weeks and marked stale or conflicting: suggest
  closing it to the human.
- One ping per repo covering sibling PRs, then wait two weeks.
- Close your own duplicates and anything superseded, with a short neutral note.
- Only list merged PRs on a public profile.

## References

- `references/verification-traps.md`: ways a check looks green while being wrong.
- `references/windows.md`: toolchain traps on Windows.
- `references/lessons.md`: every rule above with the incident that taught it.
- `scripts/pr-sweep.sh [SINCE]`: read-only sweep of your upstream PRs.
