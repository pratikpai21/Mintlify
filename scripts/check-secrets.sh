#!/usr/bin/env bash
# Firewall for the public help site. The owner's standing rule: this site is for
# clients only, and must never show secrets, code, APIs, developer features, how
# oneCommerce works inside, suppliers, costs or client names.
#
# Runs before every commit and push (scripts/hooks) and on GitHub for every push
# and pull request. If it flags something, rewrite it for clients.
# Never weaken or skip this check; add to it when something new must stay out.
set -euo pipefail
cd "$(dirname "$0")/.."

exec perl -CSD -Mutf8 -e '
use strict; use warnings;
my $fail = 0;
sub bad { print "✗ $_[0]\n"; $fail = 1 }

# 1. Only these files may exist in the repo. No API specs, scripts, styles,
#    custom code or snippets: nothing that could carry developer content.
my @allowed = (
  qr{^[a-z0-9-]+\.mdx$}, qr{^[a-z0-9-]+/[a-z0-9-]+\.mdx$},
  qr{^docs\.json$}, qr{^favicon\.svg$}, qr{^logo/(light|dark)\.svg$},
  qr{^images/[a-z0-9-]+\.(png|jpe?g|webp|gif|svg)$},
  qr{^(AGENTS\.md|README\.md|LICENSE|\.mintignore|\.gitignore)$},
  qr{^scripts/check-secrets\.sh$}, qr{^scripts/hooks/(pre-commit|pre-push)$},
  qr{^\.github/workflows/safety-check\.yml$},
);
my @files = grep { -f } split /\n/, `git ls-files --cached --others --exclude-standard`;
for my $f (@files) {
  bad("file not allowed on the help site: $f") unless grep { $f =~ $_ } @allowed;
  bad("API or developer section not allowed: $f") if $f =~ m{(^|/)(api|apis|api-reference|reference|developers?|sdk|openapi|snippets)(/|\.|$)}i;
}

# 2. Site settings: no API playground, API specs, AI/MCP connectors or custom code.
if (open my $j, "<", "docs.json") {
  local $/; my $s = <$j>;
  for my $k (qw(openapi asyncapi api playground contextual mcp integrations scripts styles)) {
    bad("docs.json: \"$k\" setting not allowed") if $s =~ /"\Q$k\E"\s*:/;
  }
}

# 3. Page text. Published pages and site settings only.
my @pages = grep { /\.mdx$/ || $_ eq "docs.json" } @files;

# Words and patterns that must never appear (case-insensitive).
my @blocked = (
  # secrets and keys
  qr{\b(sk-[a-z0-9-]{8,}|shp(at|ss|ca|pa)_[a-f0-9]+|gh[pousr]_[a-z0-9]{10,}|github_pat_|AKIA[0-9A-Z]{12,}|xox[abp]-|AIza[0-9a-z_-]{20,})}i,
  qr{-----BEGIN [A-Z ]*KEY-----}i, qr{\bbearer\b}i, qr{\b(client|api|app) ?(id|secret|key)s?\b}i,
  qr{(?<![\w/.-])[A-Za-z0-9+/_-]{32,}(?![\w/.-])},
  qr{\b(api ?keys?|access ?tokens?|tokens?|passwords? ?(file|hash)|hash(ed)?|encrypt\w*|unlock key)\b}i,
  # developer and API features
  qr{\b(apis?|sdks?|developers?|dev ?dashboard|endpoints?|webhooks?|graphql|rest|json|yaml|curl|scopes?|oauth|hmac|cli)\b}i,
  qr{\b(GET|POST|PUT|PATCH|DELETE)\s+/}, qr{/api/}i, qr{\b(read|write)_[a-z_]+\b}i,
  qr{\b[A-Z][A-Z0-9]*_[A-Z0-9_]{2,}\b},
  qr{\b(source code|codebase|code snippet|repo(sitory)?|github|git|commit|branch|deploy(ment|ed)?|release notes|version \d|v\d+\.\d+)\b}i,
  # how it works inside
  qr{\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b},
  qr{(^|[\s(`])/(opt|etc|usr|var|root|home|src|data|backups|public|test)/}i,
  qr{\binbox-[a-z0-9-]+}i,
  qr{\b(servers?|hosting|hosted on|host(ed)? by|vps|data ?cent(er|re)|ssh|sudo|systemd|caddy|nginx|docker|fail2ban|hostinger|localhost|ports? ?\d+)\b}i,
  qr{(\.env|\.db|\.js|\.ts|\.json|\.sh|\.py|README)\b}i,
  qr{\b(node(\.js)?|npm|express|socket\.io|sqlite|database|baileys|whatsmeow|puppeteer|websocket)\b}i,
  qr{\b(anthropic|claude|haiku|sonnet|opus|openai|gpt|llm|ai models?|model)\b}i,
  qr{\b(cloudflare|r2|rclone|healthchecks|kie|mintlify)\b}i,
  # suppliers, clients, money, plans
  qr{\b(shipprime|batteryworks|tanvi|drrucha|rucha)\b}i,
  qr{\b(our costs?|margins?|wholesale|suppliers?|per[- ]token)\b}i,
  qr{\b(roadmap|not built yet|coming soon|todo|tbd|fixme)\b}i,
  qr{\[\[[A-Z_]+\]\]},
);
# Code and custom components that only developers need.
my @code = (
  qr{^\s*(```|~~~)}, qr{<(CodeGroup|RequestExample|ResponseExample|ParamField|ResponseField|Expandable|Snippet|script|iframe|style)\b}i,
  qr{^\s*(import|export)\s},
);
# Only these sites may be linked.
my $okhost = qr{^(onecommerce\.tech|app\.onecommerce\.tech|docs\.onecommerce\.tech|wa\.me)$}i;

for my $f (@pages) {
  open my $h, "<", $f or next;
  while (my $line = <$h>) {
    next if $line =~ /"\$schema"/;
    my $where = "$f:$.";
    for my $p (@blocked) { if ($line =~ $p) { bad("$where blocked word \"$&\": $line"); last } }
    for my $p (@code)    { bad("$where code is not allowed: $line") if $line =~ $p }
    while ($line =~ m{\b(https?)://([^/\s)"\x27>]+)}g) {
      bad("$where only https links: $line") if $1 eq "http";
      bad("$where link to $2 not allowed: $line") unless $2 =~ $okhost;
    }
    # Inline code is only for sample web addresses (yourstore.myshopify.com).
    while ($line =~ /`([^`]*)`/g) {
      my $c = $1;
      bad("$where only sample web addresses may be in `code`: `$c`") unless $c =~ /^[a-z0-9.-]+\.(com|tech|in)$/i;
    }
    bad("$where mailto only to support: $line") if $line =~ /mailto:(?!support\@onecommerce\.tech\b)/i;
  }
}

if ($fail) {
  print "\nHelp site firewall FAILED. The lines above must not be published. Rewrite them for clients.\n";
  exit 1;
}
print "Help site firewall passed (", scalar(@pages), " pages checked, ", scalar(@files), " files allowed).\n";
'
