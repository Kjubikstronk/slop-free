#!/usr/bin/env bash
# Read-only sweep of your PRs to repos you don't own, covering the places a reply
# hides: inline review threads, unresolved threads, closed PRs, and timeline events
# (labels, assigns, reviews) that never show up as comments.
#
# Usage: pr-sweep.sh [SINCE]      SINCE is an ISO timestamp, default 3 days ago.
# Needs: an authenticated gh. No separate jq install; gh's --jq is enough.
set -uo pipefail

SINCE="${1:-$(date -u -d '3 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-3d +%Y-%m-%dT%H:%M:%SZ)}"
ME="$(gh api user --jq .login)" || { echo "gh is not authenticated" >&2; exit 1; }
LIST="$(mktemp)"
SEEN="$(mktemp)"
trap 'rm -f "$LIST" "$SEEN"' EXIT

search() {
  gh api -X GET search/issues -f q="type:pr author:$ME -user:$ME $1" -f per_page=100 --jq \
    '.items[] | "\(.repository_url | split("/") | .[-2] + "/" + .[-1]) \(.number) \(.state) \(.updated_at) \(.title)"'
}

echo "== $ME, since $SINCE"
echo
echo "## 1. Open PRs"
search "state:open" | sort | tee -a "$LIST" | while read -r repo num _ updated title; do
  echo "  $repo#$num  updated $updated  $title"
done

echo
echo "## 2. Closed or merged since $SINCE"
search "state:closed updated:>=${SINCE%%T*}" | sort | tee -a "$LIST" | while read -r repo num _ _ title; do
  merged=$(gh api "repos/$repo/pulls/$num" --jq '.merged_at // "not merged"')
  echo "  $repo#$num  $merged  $title"
done

echo
echo "## 3. Inline threads whose last word isn't yours (bots excluded)"
while read -r repo num _; do
  out=$(gh api "repos/$repo/pulls/$num/comments?per_page=100" --jq '
    group_by(.in_reply_to_id // .id)[] | (sort_by(.created_at) | last)
    | select(.user.login != "'"$ME"'" and .user.type != "Bot")
    | "    \(.user.login) \(.created_at): \(.body | gsub("\n"; " ") | .[0:140])"')
  [ -n "$out" ] && printf '  %s#%s\n%s\n' "$repo" "$num" "$out"
done < "$LIST"

echo
echo "## 4. Unresolved review threads, bots included (each needs a fix or a reason, then resolving)"
while read -r repo num state _; do
  [ "$state" = "open" ] || continue
  out=$(gh api graphql -F o="${repo%/*}" -F r="${repo#*/}" -F n="$num" -f query='
    query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){
      reviewThreads(first:100){nodes{isResolved comments(first:1){nodes{author{login} body}}}}}}}' --jq '
    .data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not)
    | .comments.nodes[0] | "    \(.author.login): \(.body | gsub("\n"; " ") | .[0:140])"')
  [ -n "$out" ] && printf '  %s#%s\n%s\n' "$repo" "$num" "$out"
done < "$LIST"

echo
echo "## 5. Timeline events since $SINCE (labels, assigns, reviews, closes)"
while read -r repo num _; do
  out=$(gh api "repos/$repo/issues/$num/timeline?per_page=100" --jq '
    .[] | (.created_at // .submitted_at) as $t
    | select($t != null and $t >= "'"$SINCE"'")
    | select((.actor.login // .user.login // "") != "'"$ME"'")
    | "    \(.event) by \(.actor.login // .user.login // "?") at \($t) \(.label.name // .assignee.login // .state // "")"' 2>/dev/null)
  [ -n "$out" ] && printf '  %s#%s\n%s\n' "$repo" "$num" "$out"
done < "$LIST"

echo
echo "## 6. Open PRs: mergeability, reviews, CI"
while read -r repo num state _; do
  [ "$state" = "open" ] || continue
  m=$(gh api "repos/$repo/pulls/$num" --jq '"\(.mergeable_state)"')
  r=$(gh api "repos/$repo/pulls/$num/reviews?per_page=100" --jq '[.[] | select(.user.login != "'"$ME"'") | .state] | unique | join(",")')
  sha=$(gh api "repos/$repo/pulls/$num" --jq .head.sha)
  ci=$(gh api "repos/$repo/commits/$sha/check-runs?per_page=100" --jq '[.check_runs[] | .conclusion // "pending"] | map(select(. == "failure" or . == "pending" or . == "action_required")) | unique | join(",")')
  # Some projects report CI as commit statuses rather than check runs.
  st=$(gh api "repos/$repo/commits/$sha/status" --jq 'if .total_count == 0 then "" else .state end')
  if [ "$st" = "failure" ] || [ "$st" = "pending" ]; then ci="${ci:+$ci,}status:$st"; fi
  printf '  %-40s %-10s reviews=%-28s ci=%s\n' "$repo#$num" "$m" "${r:-none}" "${ci:-ok}"
done < "$LIST"

echo
echo "## 7. Elsewhere: comments about your PRs on other threads"
# Feedback on your PR often lands on a competing PR or on the issue instead, where
# none of the sections above look. Check the threads that link to each open PR, and
# anything that @-mentions you.
while read -r repo num state _; do
  [ "$state" = "open" ] || continue
  gh api "repos/$repo/issues/$num/timeline?per_page=100" --jq '
    .[] | select(.event == "cross-referenced") | .source.issue
    | "\(.repository_url | split("/") | .[-2] + "/" + .[-1]) \(.number)"' 2>/dev/null |
  sort -u | while read -r xrepo xnum; do
    out=$(gh api "repos/$xrepo/issues/$xnum/comments?per_page=100&since=$SINCE" --jq '
      .[] | select(.user.login != "'"$ME"'" and .user.type != "Bot")
      | select(.body | test("#'"$num"'\\b|/pull/'"$num"'\\b|@'"$ME"'\\b"; "i"))
      | "    \(.user.login) \(.created_at): \(.body | gsub("\n"; " ") | .[0:140])"' 2>/dev/null)
    [ -n "$out" ] && { printf '  %s#%s, about %s#%s\n%s\n' "$xrepo" "$xnum" "$repo" "$num" "$out"; echo "$xrepo#$xnum" >> "$SEEN"; }
  done
done < "$LIST"
gh api -X GET search/issues -f q="mentions:$ME updated:>=${SINCE%%T*}" -f per_page=50 --jq '
  .items[] | "\(.repository_url | split("/") | .[-2] + "/" + .[-1]) \(.number)"' 2>/dev/null |
while read -r xrepo xnum; do
  grep -qxF "$xrepo#$xnum" "$SEEN" && continue
  out=$(gh api "repos/$xrepo/issues/$xnum/comments?per_page=100&since=$SINCE" --jq '
    .[] | select(.user.login != "'"$ME"'" and .user.type != "Bot")
    | select(.body | test("@'"$ME"'\\b"; "i"))
    | "    \(.user.login) \(.created_at): \(.body | gsub("\n"; " ") | .[0:140])"' 2>/dev/null)
  [ -n "$out" ] && printf '  %s#%s mentions you\n%s\n' "$xrepo" "$xnum" "$out"
done
echo "  (no lines means nothing found)"

echo
echo "## Also check by hand"
echo "  Notification email from notifications@github.com since $SINCE (the web list truncates)."
echo "  Issues you opened: gh api -X GET search/issues -f q='type:issue author:$ME updated:>=${SINCE%%T*}'"
