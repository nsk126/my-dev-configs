#!/bin/bash
# Status line: (1) cwd (~ for $HOME), (2) git branch (omitted outside a
# repo), (3) context window remaining, (4) usage segments mirroring the
# /usage screen: session (5h), per-model weekly (e.g. Fable), all-models
# weekly (7d).
#
# Note on (4): verified against a live payload captured from this harness
# (not just the documented schema) -- rate_limits only ever contains
# five_hour / seven_day / spend_limit (all account-level). There is NO
# per-model (Fable/Opus/etc.) weekly-limit field in the payload today, so
# the "Fable:" segment below is a stub, gracefully skipped, kept in case a
# future harness version adds one under a guessed key (update FABLE_KEYS
# if/when Anthropic documents the real key name).

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# git branch, gracefully omitted when cwd isn't inside a git repo
# (must run on the raw path before the ~ substitution below)
branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

# show $HOME as ~, like bash's \w
case "$cwd" in
    "$HOME") cwd="~" ;;
    "$HOME"/*) cwd="~${cwd#$HOME}" ;;
esac

# context window remaining (percentage)
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# three usage segments, side by side like /usage: session (5h), per-model
# weekly (not present in the current payload -- see note above), and the
# all-models weekly window (7d). Values shown are %used, matching /usage.
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
fable=$(echo "$input" | jq -r '.rate_limits.seven_day_opus.used_percentage // .rate_limits.seven_day_model.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
spend=$(echo "$input" | jq -r '.rate_limits.spend_limit.used_percentage // empty')

out=$(printf '\033[01;34m%s\033[00m' "$cwd")
[ -n "$branch" ] && out="$out $(printf '\033[01;32m(%s)\033[00m' "$branch")"

if [ -n "$ctx_remaining" ]; then
    out="$out | Ctx: $(printf '%.0f' "$ctx_remaining")% left"
fi

if [ -n "$five" ]; then
    out="$out | 5h: $(printf '%.0f' "$five")%"
fi

if [ -n "$fable" ]; then
    out="$out | Fable: $(printf '%.0f' "$fable")%"
fi

if [ -n "$week" ]; then
    out="$out | Wk: $(printf '%.0f' "$week")%"
elif [ -n "$spend" ]; then
    out="$out | Spend: $(printf '%.0f' "$spend")%"
fi

printf '%s' "$out"
