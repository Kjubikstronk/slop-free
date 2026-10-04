# Templates

Starting points, not forms to fill. Match the repo's own tone and length first: if
its merged PRs are three lines, yours is three lines. Replace everything in
`<angle brackets>`, and delete any line that doesn't apply rather than writing
"N/A". If a project requires the contributor's own words, these are for the human
to adapt, not for the agent to post.

## PR description

Use the repo's template if it has one, and put this content into its sections.

```
<One or two sentences: what was wrong, as a user would see it. Link the issue.>

<Why it happened: the root cause in a sentence or two, pointing at the function.>

<What changed, only where the diff doesn't make it obvious.>

<How it's tested: the new test, and that it fails without the fix.>

<Anything you deliberately left alone, and anything you couldn't run locally.>

<Disclosure line, in the form the project asks for.>
```

A small example:

```
Fixes #123. `parseRange("1-")` returned `[1, NaN]` instead of throwing.

The upper bound was parsed with `Number("")`, which is 0 after coercion in one
branch and NaN in the other. It now throws the same `RangeError` as `"-1"`.

Added a test for the open-ended case; it fails on main.
```

## Replies to review comments

One reply per thread, in that thread. Never a summary comment covering several.

- **You fixed it:** `Fixed in <short sha>.` Add one sentence only if the fix
  differs from what they suggested.
- **You're not changing it:** say why in one or two sentences, with evidence, and
  offer the alternative if there is one.
  `Leaving this as is: <reason>. Happy to switch to <alternative> if you'd prefer.`
- **The suggestion would break something:** show the case, don't argue.
  ```
  That would bring the bug back for this input:
  <smallest example>
  It prints <wrong>; native/expected prints <right>. Added it as a test.
  ```
- **The comment is about code you didn't touch:** `This is pre-existing on main
  (<link to line>), so I've left it out of this PR.`
- **You don't know yet:** `Good question, I'll check and come back.` Then do.

## Asking before you code

When an issue could be fixed two ways, ask with a small table instead of guessing.

```
Before I write this, which behaviour do you want?

| input | option A | option B |
| --- | --- | --- |
| <case> | <result> | <result> |

A matches <reference>, B is closer to the current docs.
```

## Claiming and releasing an issue

```
I'd like to fix this. I've reproduced it on main and found the cause in <file>.
```

```
I won't get to this after all, so it's free for anyone.
```

## A competing PR

```
#<n> also fixes this. Mine differs in <one concrete point>. Happy to close mine
if you'd rather go with theirs.
```

## Closing

- Maintainer asked: `Thanks for looking. Closing.`
- Superseded: `Closing this, #<n> landed the same fix.`
- Your own duplicate: `Closing in favour of #<n>.`

## A nudge

One per repo, covering all your open PRs there, then wait two weeks.

```
Hi, gentle nudge on this one (and #<n>). Rebased on main, CI is green. Happy to
change anything.
```

## Correcting an AI review bot

When a bot saves your reply as a project rule credited to the maintainers:

```
@<bot> I'm a contributor, not a maintainer, so please don't record this as a
repo-wide preference.
```

## Disclosure lines

Use the project's own wording if it has one. Otherwise, one plain line:

- `I used an AI coding assistant for parts of this and reviewed and tested every change.`
- On a drafted comment, where the project allows them, as the first line:
  `This reply was drafted with an LLM. I checked it and ran the examples before posting.`
