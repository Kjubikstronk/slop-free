# Verification traps

Every one of these produced a green result for a check that was wrong or never ran.
Before reporting a pass, ask which of them could apply.

## The check didn't run

- **Flags after `--` are pathspecs.** `git stash push -- <path> --quiet` treats
  `--quiet` as a path and errors, so the "baseline" was taken on the modified tree.
  Put flags before `--`.
- **`$?` after a pipe is the last command's exit code.** `eslint . | tail; echo $?`
  printed 0 while eslint exited 2 on a missing plugin. Lint had never run. Use
  `set -o pipefail` or run the tool on its own line.
- **A loop over a file list with CRLF endings.** Every path "didn't exist", and the
  loop still printed 0 failures. Strip `\r` first.
- **A test-name filter isn't a test list.** A filter meant to cover one module
  matched one unrelated test. Run against the project's own list of known-passing
  tests instead.
- **Shallow clones make history searches empty.** `git log -S` on a depth-limited
  clone found nothing and exited 0. Deepen the clone before concluding anything.
- **A harness that only prints totals.** "1 tests passed" per file says nothing
  about your new test. Break its expectation once and watch it fail.

## The check ran against the wrong code

- **Tests that import a built bundle.** If tests resolve through `lib/` or `dist/`,
  a source edit tests nothing until you rebuild. Change, baseline and mutation runs
  all printed the same 68/68.
- **A clean `git status` isn't a clean build.** A stale build carrying a lost local
  patch produced a public "doesn't reproduce on main" comment that had to be
  corrected. Clear the build output and assert on something you just changed.
- **Dependencies from before a rebase.** The new base added a lint plugin, and lint
  failed to load its config instead of linting.

## The check passes whatever the code does

- **"Nothing threw" isn't a result.** A probe reported PASS because parsing didn't
  throw, while the emitted output was split in two.
- **Know how the harness compares.** One spec runner ignores whitespace by default,
  so a whitespace fix passed with and without the change until exact comparison was
  switched on.
- **A suite can be green while your change breaks shapes it never tests.** Build
  adversarial inputs by hand and diff against a reference implementation. For
  compatibility work, a differential run against the reference is the strongest
  evidence there is.
- **Timing guards.** A ratio of two sub-millisecond timings went red on a loaded
  runner, and the axis being scaled was linear for both versions anyway. Use an
  absolute budget at an input size where the bad version loses 10x or more, take
  the best of N runs, and scale the axis that's actually superlinear.

## Reading CI

- **Parse `gh pr checks` with a tab separator.** Check names contain spaces, so
  `awk '$2=="pending"'` read "14" from "Node.js 14 on Linux" and declared CI done
  with 16 jobs still running.
- **Read the job's conclusion, not the summary.** A "failed" job had been cancelled
  with zero failed steps, and was cancelled on main too.
- **Infrastructure failures look like test failures.** Seen in practice: a Windows
  DLL-init crash (exit 0xC0000142) while building a package the PR didn't touch, a
  1px text shift in a visual snapshot the tool itself rated flaky, and a retired
  runner image. Compare with main before touching code.
