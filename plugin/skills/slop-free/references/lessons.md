# Lessons and the incidents behind them

Two months of agent-assisted bug-fix PRs to about 25 open-source projects, kept as
working notes and anonymized here. Each rule is followed by the incident that taught it.

## 1. Choosing a repo and a bug

- Measure distinct outside authors merged in the last ~2 months, not open-issue count.
  Taught by: two very active repos merged 80 PRs in two months from only 3-4 authors, all core team. Many issues plus few authors means closed in practice.
- Require live maintainers: merges in the last 2 weeks and human replies on outside PRs.
  Taught by: four PRs to one library got no response for weeks; nobody's PR had merged there in months, and all four were eventually closed.
- Respect a written policy that declines agent-assisted or agent-primary contributions: don't contribute there.
  Taught by: a sound 50-line PR with tests was closed within days at a project whose public AI policy said exactly that. Nobody had read it first.
- Find a category the repo demonstrably merges, then audit the source for unfiled instances of it.
  Taught by: five merged accessibility PRs linked from one issue proved the category; scanning 86 UI files for the same two patterns found real bugs nobody had filed.
- Expect most audit hits to be false positives, and cross-check open PRs' file lists before writing anything.
  Taught by: of 14 audit hits, 4 were already correct or regex artifacts and 3 were already covered by someone's open PR.
- Prefer a narrow, demonstrable wrong output over a fix that tunes a heuristic.
  Taught by: at a large formatter project, PRs that shifted comment-placement heuristics were closed (one as low quality) while narrow markdown/CSS fixes merged the same week.
- Quality bar: would a competent human be confident in this diff after reading it once? If it needs a paragraph of defence, don't open it.
  Taught by: standing rule adopted after watching projects restrict outside contributions because of low-quality AI PRs.
- Treat "approved" / "accepting PRs" labels as "wanted", not "small" and not "still broken".
  Taught by: an approved issue in a diagram library had already been fixed and released; two other approved issues there needed parser/grammar rewrites.
- Before believing an open issue, test the reporter's version against current main or the latest release.
  Taught by: `npm pack pkg@<reporter's version>` plus a grep of the bundle showed the bug already fixed in a later release; a 30-second check saved a duplicate PR.
- Reproduce an issue's premise before trusting its proposed fix, especially in batches of same-template issues.
  Taught by: a "flaky test" issue passed 5/5 isolated, 6/6 under injected delay and 9/9 in the full file. It was dropped with no PR.
- Check how fast triaged bugs get picked up before investing.
  Taught by: in one popular build tool every recent triaged bug had a PR within 1-2 days; a markdown parser had a dozen open fix PRs from new accounts.
- Prefer repos where humans review; expect competition where automation also lands fixes.
  Taught by: an outside PR sat unreviewed for six days while an identical change landed through another PR without referencing it.

## 2. Before writing code

- Read CONTRIBUTING, the PR template and any AI/agent policy first, before investigating.
  Taught by: two good accessibility PRs were closed for arriving without a linked, maintainer-approved issue; the rule was stated plainly in CONTRIBUTING.
- Search open AND closed PRs and issues, including your own, before reading an issue in depth.
  Taught by: a full investigation and PR duplicated the contributor's own better PR for the same issue, open for two weeks. `gh pr list --author @me` takes a second.
- Search for competing PRs by the file and function you would change, not only by the issue.
  Taught by: a PR duplicated an earlier one whose title used different words. The earlier one merged with the identical one-line fix.
- Check labels and comments first: team-only, claimed, already fixed on main.
  Taught by: 8 of 27 open bugs in a Java framework were labelled team-only, and a maintainer had turned down a volunteer on exactly that basis.
- Check the code isn't being moved or rewritten.
  Taught by: a PR was closed because the module it touched was being relocated.
- Confirm the change is wanted (accepting-PRs label, maintainer request, proven category); otherwise ask on the issue first.
  Taught by: two formatter PRs about behaviour nobody had asked about were closed the same morning ("I don't think we want this change").
- When a maintainer endorses a direction that fits two semantics, post a small case matrix and ask which before coding.
  Taught by: a test-runner matcher fix could mean strict parity with another library or a looser reading; a 4-row table and one question went out before any code.
- If an existing test asserts the current behaviour, it's a design decision: raise it, don't send an unasked PR.
  Taught by: a sitemap edge case looked wrong, but an existing test asserted exactly that output; it was parked for a maintainer decision.
- Claim by exposure: fresh issue on a busy repo, claim first; old obscure issue, just fix it; anything you'd sleep on, claim.
  Taught by: an unclaimed fix lost to an identical patch six days later; a year-dormant issue needed no claim at all.
- Bound every claim; if work hasn't started within a couple of days, say you're dropping it.
  Taught by: a year-old stale claim was released with one polite comment. Stale claims cost nothing; blocking others does.
- A claim without code isn't ownership. If you already hold the diagnosis and code, say so plainly, link it, offer to stand down, never accuse.
  Taught by: a claim posted 30 minutes after an issue was filed restated the filer's own plan and never produced a PR.
- Cap volume: max 2 open PRs per repo, 3 new per week, none while 15+ are open. Maintaining existing PRs beats opening new ones.
  Taught by: an audit found 23 open PRs, four repos over cap and 9 opened in one week; new work was frozen until the queue shrank.
- Some repos cap open PRs per outside contributor in their settings.
  Taught by: a 4th `gh pr create` failed with "does not have the correct permissions to execute CreatePullRequest". Queue ready fixes on pushed branches.
- Agent-directed text in CONTRIBUTING/AGENTS.md tells you the policy: follow it (lint scripts, own-words rules, disclosure), never route around it.
  Taught by: one repo's AGENTS.md targeted agent-written PR descriptions; its policy required the human's own description, which is the honest path anyway.
- Some projects bar AI help on good-first-issue items or for first-time contributors. Check before choosing the issue.
  Taught by: a runtime's AI guidelines and an ML library's PR template both say so explicitly.

## 3. The fix

- Fix the root cause where callers route through; if a change only makes the test pass, say so and stop.
  Taught by: one formatter bug needed three separate defects fixed along one code path; tracing every caller is what found them.
- Never edit an existing fixture or expectation just to make your change pass.
  Taught by: a PR that rewrote existing expectations to fit new behaviour was closed. Some projects require a human to verify any changed assertion.
- If an existing expectation is genuinely wrong, call it out explicitly and have a human check it.
  Taught by: a runtime's inspect test enshrined an indentation leak; the PR corrected it, said why, and the human verified the changed assertion.
- Smallest diff in the repo's style, one bug per PR, split by component the way the repo split its own merged work.
  Taught by: an accessibility audit was split per component exactly as the repo's own merged a11y PRs had been.
- Match the idiom of recently merged PRs exactly, and reuse the repo's existing helpers and patterns.
  Taught by: merged a11y fixes used a real `<button>` with `all: unset` and each package's own focus-ring variable, not `role="button"` on a div.
- Keep only the check that can fail; guards that exist to satisfy the type checker are dead code. Cast instead.
  Taught by: a reviewer approved but asked to delete two of three added clauses, noting no test case could distinguish them.
- Match the file's comment density; the "why" belongs in the commit message and PR, not a comment block.
  Taught by: a six-line comment above a three-line constant was what reviewers objected to; one-line examples in the file's own style were fine.
- When porting from a reference implementation, don't port its bugs; say so and offer to match if asked.
  Taught by: a compat port skipped the reference's own indentation leak, and the leak got its own upstream PR instead.
- List deliberately out-of-scope cases in the PR body, verified as pre-existing on clean main.
  Taught by: two still-unstable variants were documented up front, so the maintainer's obvious question already had an answer.
- Don't fix environment problems (broken hooks, test launchers) in the PR; keep local workarounds out of commits.
  Taught by: a suite only ran after a local patch pointing browser tests at the system Chrome; that patch was never committed.

## 4. Verification

- Baseline the full suite on the unmodified tree first; compare the failing set, not the count.
  Taught by: a formatter's clean upstream had 66 failing tests across 22 suites; a date library had 124 failures on a newer Node.
- Teeth-check every new test: revert the fix, confirm it fails, restore. Label any test that passes both ways as a control.
  Taught by: a mutation that should have broken a fixture still passed, which is how a stale build was caught (see verification-traps.md).
- Assert on the produced value, never on "nothing threw".
  Taught by: a probe reported PASS for a CSS comment because parsing didn't throw; the emitted style was split in two.
- Run the repo's own formatter, linter and typecheck before pushing, not just the tests.
  Taught by: CI lint failed twice on things tests never see: one line over 80 chars, and `Infinity` where a rule wants `Number.POSITIVE_INFINITY`.
- Test the sentence in the PR you're least sure of; if a check can't run locally, say so in the PR.
  Taught by: "should be visually neutral" shipped untested; visual-regression CI caught broken inline layout (a `<p>` around a flex child is a layout change).
- Verify every claim before posting it, not after.
  Taught by: half of a posted root-cause claim (about HTML entities) was wrong and needed a public correction.
- Prefer reporting a measured negative result over shipping an uncertain fix.
  Taught by: reproductions showing "already fixed" or "not a bug" earned more maintainer goodwill than several of the fixes did.
- The other green-but-wrong cases (pipe exit codes, stale builds, harness comparison, CI parsing)
  are in verification-traps.md.

## 5. Writing the PR

- The human sees the full diff and exact text before any public action: open, push, comment, reply. They must be able to explain every line.
  Taught by: a standing "post without asking" permission was revoked after closed PRs; every PR is the human's reputation.
- Disclose AI use in exactly the form the project asks (template checkbox, commit trailer, PR-body line, disclaimer before drafted text). Check before the first commit.
  Taught by: a DOM library asked for its required AI trailer back after a squash dropped it; a test runner's template asks agents to state authorship and review status.
- Where a project requires the human's own words, the human writes the description, comments and replies. The agent supplies facts and formatting only.
  Taught by: a compiler project's policy requires it. What works: the agent hands over facts, the human writes, the agent only fixes code spans and typos.
- Where LLM-drafted comments are allowed with a disclaimer, the disclaimer goes on the first line.
  Taught by: a review reply opened with "This reply was drafted with an LLM. I checked it and ran the examples before posting."
- Where a project forbids PRs opened by automated tooling, the human opens it from the compare link.
  Taught by: a runtime's AI guidelines say so; the agent prepared the branch and the human clicked create.
- Where a project asks for the real-world motivation, use the human's actual one. Never invent it.
  Taught by: "working through the failing-test list" doesn't count as a use case for one DOM project.
- Check CLA, DCO sign-off and commit-format rules at the first commit.
  Taught by: three PRs sat unmergeable over an unsigned CLA that only the human can sign; another project needs `Signed-off-by`, subsystem-prefixed subjects and brand names only in the PR body.
- Follow the template and title convention: issue-link line, changeset, changelog entry.
  Taught by: one formatter wants the changelog added after opening, because the file is named by PR number.
- Read recent merged PRs first. Length depends on engagement: evidence-dense in an ongoing thread, short and plain for a first PR; skip test lists where the repo says CI covers it.
  Taught by: measurement-heavy writeups earned credit at three repos; one AI policy names diff-restating descriptions as adding no value.
- Never restate the diff. Say why, what you checked, and what you didn't fix.
  Taught by: descriptions that walked the diff line by line were the pattern maintainers objected to.
- Cut drafts hard: no headers on a few lines of content, one table at most, no stacked bold labels, no closing aphorism.
  Taught by: drafts were repeatedly too long and too complete; roughly half the length was usually right.

## 6. After opening: reviews, bots, CI, reply sweeps

- Reply to each review comment in its own thread. Never a batch summary.
  Taught by: a maintainer asked to stop posting "All three done", since a reader in one thread has no context for "three".
- Don't edit or delete a reply someone has already answered; change the next one instead.
  Taught by: an edit under an existing response leaves it dangling and reads as covering tracks.
- Answer every review comment, bots included: fix it or give the reason, then resolve the thread.
  Taught by: a bot "P1" about a getter read twice concerned pre-existing code, not the PR; the right answer was to say so with evidence.
- Answer a wrong suggestion with a concrete counterexample, not an opinion.
  Taught by: a reviewer's requested change would have reintroduced the bug for `{ fn = () => name }`; showing that case settled it.
- Don't reopen stale threads on a PR the maintainer has since approved; resolve them.
  Taught by: an unresolved thread the maintainer approved past was a checkbox, not open feedback.
- On red CI, decide "mine or flaky" first: compare the same job on main and read the job conclusion, not the summary.
  Taught by: a "failed" job was cancelled with zero failed steps and cancelled on main too; others were a DLL-init crash, a 1px visual diff and a retired runner.
- First-time contributors' CI often waits for a maintainer to start it; fork contributors can't re-run upstream jobs.
  Taught by: a runtime PR's CI needed a collaborator label; nothing to do but wait.
- Sweep every channel before saying "nothing new": inline threads, closed/merged PRs, timeline events, subscribed issues, and notification email (the web list truncates).
  Taught by: a maintainer's inline hint went unanswered, a close with an explanation was missed, and a competing PR announced on an issue was invisible.
- Group inline review comments by `in_reply_to_id // id` and flag any chain whose last non-bot message isn't yours.
  Taught by: a later top-level review hid inline follow-ups, and one sat unanswered for two days.
- Timeline `reviewed` events carry `submitted_at`, not `created_at`; label and assign events aren't comments.
  Taught by: a created_at filter silently dropped every approval; a maintainer assigning and labelling PRs produced no comment at all.
- Disable Actions on your forks.
  Taught by: ~190 of ~200 notification emails in three days were fork workflow "no jobs were run" mails burying real replies.
- Resolve conflicts the way the branch is already maintained; where force-push is forbidden, merge main in with a new commit.
  Taught by: one branch kept merge-style history while two others were rebased; one runtime's rules forbid force-push.
- If a competing PR appears, post one factual comment so the maintainer sees both. If theirs merges, close yours with one line.
  Taught by: a near-identical PR built on the contributor's posted diagnosis appeared on the issue; one factual comment let the maintainer see both.
- Don't argue with automated AI-activity labels on the thread; follow the repo's policy and let the patch be judged.
  Taught by: a compiler PR carried a bot's mixed-signals flag and was still reviewed on its merits and approved.
- AI review bots may store your reply as a repo-wide rule and credit it to the maintainers.
  Taught by: a bot recorded an outside contributor's "leaving this as is" as a maintainer preference; one line in the thread got it removed.

## 7. Closing and stale PRs

- When a maintainer closes it or says close: close politely, no arguing, no reopening, no appeal.
  Taught by: closes for quality or policy reasons were final every time; arguing would only add a public conflict.
- No maintainer reply for 4+ weeks AND stale or conflicting: suggest closing to the human.
  Taught by: four PRs in a repo with no merges from anyone in months were closed; one where a maintainer had said "will look into it" stayed open.
- One ping covering sibling PRs, then wait about two weeks.
  Taught by: nudges were batched as one comment per repo covering its sibling PRs, with a two-week no-repeat window.
- Check the stale bot's config before reacting to a Stale label.
  Taught by: `days-before-pr-close: -1` meant the label would never close anything.
- Close your own duplicates and PRs superseded by a maintainer's own PR, with a short neutral note.
  Taught by: a duplicate of the contributor's own earlier PR, and one superseded by a maintainer's rewrite, were both closed without fuss.
- Leave branches that re-conflict on every upstream merge (e.g. on a changelog file) until a maintainer is ready to merge.
  Taught by: a PR touching a pre-release changelog went dirty again after every upstream merge, so it was left alone deliberately.
- List only merged PRs on a public profile.
  Taught by: an open PR linked from a profile README was later closed with a negative label and stayed linked for a week.

Toolchain lessons are in windows.md.
