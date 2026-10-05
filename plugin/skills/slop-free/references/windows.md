# Windows toolchain traps

Upstream CI often runs Windows even when maintainers don't. These cost real time.

- **`&` or a space in the clone path breaks npm/npx `.bin` shims.** npx, wireit and
  vitest resolved a truncated path. Clone to a plain path such as `C:\dev\repo`, or
  call `node node_modules/<pkg>/<entry>.mjs` directly.
- **Some `.bin` entries are POSIX shell shims.** `node node_modules/.bin/x` throws
  "missing ) after argument list". A repo's git hook did exactly that and failed on
  every Windows commit. Run the hook's checks by hand, and ask before using
  `--no-verify`.
- **`core.autocrlf=true` buries real lint errors** under thousands of `Delete ␍`
  warnings. Lint an untouched file to measure the noise. Set `core.autocrlf=false`
  locally for that repo where it matters, and keep CRLF files CRLF.
- **Tests that fail only on Windows because of CRLF fixtures.** Show they fail on
  main too, then mention it in the PR so nobody blames your change.
- **Files written by Python on Windows have CRLF.** Strip `\r` before looping over
  them in bash.
- **Agent shell tools can mangle heredocs.** Backslashes went missing even with a
  quoted delimiter, so a one-character edit silently matched nothing. Use the file
  write tool for anything with escapes.
- **Agent file tools and Git Bash can disagree on `/tmp`, and the shell's working
  directory may not persist between calls.** Use absolute paths.
- **`pnpm install` can add a platform entry to the lockfile.** Never commit that.
- **`NoDefaultCurrentDirectoryInExePath=1` makes `script.bat` "not found"** even
  from its own directory. Clear it in that cmd session only.
- **Native builds need room**: 20-25 GB target directories and first builds of
  10-30 minutes. Check the disk before starting.
- **Build dependencies the docs forget** (cmake, libclang) can come from PyPI into
  a venv inside the clone, excluded through `.git/info/exclude`. Ask before
  installing anything system-wide.
- **Symlink tests fail with EPERM without Developer Mode.** Say so in the PR rather
  than skipping them silently.
- **Some lint scripts fail on any untracked top-level file**, build logs included.
  Keep logs and scratch files outside the tree.
- **Check which remote is the fork.** In one clone `origin` was a stale fork, not
  upstream. Look before you reset or push.
