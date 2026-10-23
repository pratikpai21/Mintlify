#!/usr/bin/env bash
# Safety check for the public help site: fails if any published page mentions
# how oneCommerce works inside (servers, commands, technology, suppliers, costs)
# or a real client. Runs on every push (GitHub Actions) and before each commit.
# If it flags a line, rewrite the sentence. Don't weaken the list.
set -euo pipefail
cd "$(dirname "$0")/.."

# One pattern per line, case-insensitive, whole words where it matters.
BLOCKED='
\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b
/(opt|etc|usr|var|root|home)/
\binbox-[a-z0-9-]+
\b(hostinger|vps|ssh|sudo|systemd|caddy|nginx|docker|fail2ban)\b
\b(servers?|hosting|hosted on|data ?cent(er|re))\b
\b(backups?/|data/|auth-retired|\.env|\.db|\.js|\.json|\.sh|README)\b
\b(node(\.js)?|npm|express|socket\.io|sqlite|database|baileys|whatsmeow|puppeteer)\b
\b(source code|codebase|repo(sitory)?|github|commit|deploy(ment)?|api ?keys?|webhooks?|endpoints?|tokens?|localhost|ports?\s*\d+)\b
\b(anthropic|claude|haiku|sonnet|opus|openai|gpt|llm|model)\b
\b(cloudflare|r2|rclone|healthchecks|kie)\b
\b(shipprime|batteryworks|tanvi|drrucha|rucha)\b
\b(our costs?|margin|wholesale|supplier)\b
\b(roadmap|not built yet|todo|tbd)\b
\[\[[A-Z_]+\]\]
'

# Only what Mintlify publishes: pages and the site settings.
FILES=()
while IFS= read -r f; do [ -f "$f" ] && FILES+=("$f"); done < <(git ls-files --cached --others --exclude-standard -- '*.mdx' '*.md' 'docs.json' \
  | grep -vE '^(AGENTS\.md|README\.md|LICENSE|drafts/)|\.draft\.mdx$')

found=0
while IFS= read -r pattern; do
  [ -z "$pattern" ] && continue
  if PAT="$pattern" perl -ne 'next if /"\$schema"/; if (/$ENV{PAT}/i) { print "$ARGV:$.: $_"; $f = 1 } close ARGV if eof; END { exit($f ? 1 : 0) }' "${FILES[@]}"; then :; else
    echo "  ↑ blocked by: $pattern"
    found=1
  fi
done <<< "$BLOCKED"

if [ "$found" = 1 ]; then
  echo
  echo "Help site safety check FAILED: the lines above mention internal details. Rewrite them for clients."
  exit 1
fi
echo "Help site safety check passed (${#FILES[@]} files)."
