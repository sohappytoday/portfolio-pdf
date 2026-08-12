#!/usr/bin/env bash
# extract-css-tokens.sh — fetch a public site's HTML + linked stylesheets and
# aggregate candidate design tokens (colors, fonts, radius, shadow) by frequency.
#
# This is a SIGNAL-GATHERING tool, not ground truth. Modern SPA sites often set real
# colors via CSS-in-JS / runtime-injected variables that never appear in static CSS,
# so some semantic custom properties (e.g. --tw-semantic-color-bg-overlay400) may show
# up with no resolvable hex value here. Treat the output as candidates to cross-check
# visually (e.g. against a screenshot), not as verified final tokens.
#
# Usage: extract-css-tokens.sh <url> <output-dir>
#   <url>         page to analyze, e.g. https://www.tossinvest.com
#   <output-dir>  directory to write raw/ and tokens.md into (created if missing)

set -uo pipefail

URL="${1:?usage: extract-css-tokens.sh <url> <output-dir>}"
OUTDIR="${2:?usage: extract-css-tokens.sh <url> <output-dir>}"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
MAX_CSS_FILES=15
TIMEOUT=20

mkdir -p "$OUTDIR/raw"

echo "==> Fetching $URL"
curl -sL --max-time "$TIMEOUT" -A "$UA" "$URL" -o "$OUTDIR/raw/page.html"
if [ ! -s "$OUTDIR/raw/page.html" ]; then
  echo "!! Failed to fetch $URL (empty response). Aborting." >&2
  exit 1
fi

# Resolve origin (scheme://host) for relative URLs found in the page.
ORIGIN=$(printf '%s' "$URL" | grep -oE '^[a-zA-Z]+://[^/]+')

echo "==> Finding <link rel=\"stylesheet\"> references"
grep -oE '<link[^>]+rel="stylesheet"[^>]*>' "$OUTDIR/raw/page.html" \
  | grep -oE 'href="[^"]+"' | sed -E 's/href="([^"]+)"/\1/' > "$OUTDIR/raw/css-links.txt"
touch "$OUTDIR/raw/css-links.txt"

: > "$OUTDIR/raw/combined.css"
i=0
while IFS= read -r href; do
  [ -z "$href" ] && continue
  i=$((i + 1))
  if [ "$i" -gt "$MAX_CSS_FILES" ]; then
    echo "  (stopping at $MAX_CSS_FILES stylesheets)"
    break
  fi
  case "$href" in
    http://*|https://*) full="$href" ;;
    //*) full="https:$href" ;;
    /*) full="$ORIGIN$href" ;;
    *) full="$ORIGIN/$href" ;;
  esac
  echo "  - $full"
  curl -sL --max-time "$TIMEOUT" -A "$UA" "$full" >> "$OUTDIR/raw/combined.css" 2>/dev/null
  printf '\n' >> "$OUTDIR/raw/combined.css"
done < "$OUTDIR/raw/css-links.txt"

CSS="$OUTDIR/raw/combined.css"
TOKENS="$OUTDIR/tokens.md"
CSS_SIZE=$(wc -c < "$CSS" | tr -d ' ')

echo "==> Extracting candidate tokens -> $TOKENS (css corpus: ${CSS_SIZE} bytes)"
{
  echo "# Extracted candidate design tokens"
  echo
  echo "- Source: $URL"
  echo "- Stylesheets fetched: $i (from $(wc -l < "$OUTDIR/raw/css-links.txt" | tr -d ' ') found, cap $MAX_CSS_FILES)"
  echo "- CSS corpus size: ${CSS_SIZE} bytes"
  echo "- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "**This is frequency-based signal from static CSS, not verified ground truth.**"
  echo "Cross-check visually before treating any value as final."
  echo
  echo "## Top hex colors (by frequency)"
  echo '```'
  grep -oE '#[0-9a-fA-F]{3,8}\b' "$CSS" | tr 'A-F' 'a-f' | sort | uniq -c | sort -rn | head -30 || true
  echo '```'
  echo
  echo "## Font families referenced"
  echo '```'
  grep -oE 'font-family:[^;{}]+' "$CSS" | sort -u | head -20 || true
  echo '```'
  echo
  echo "## border-radius values (by frequency) — shape language"
  echo '```'
  grep -oE 'border-radius:[^;{}]+' "$CSS" | sort | uniq -c | sort -rn | head -20 || true
  echo '```'
  echo
  echo "## box-shadow patterns (unique samples) — elevation style"
  echo '```'
  grep -oE 'box-shadow:[^;{}]+' "$CSS" | sort -u | head -15 || true
  echo '```'
  echo
  echo "## Named custom-property color assignments (--token-name: #hex)"
  echo '```'
  grep -oE -- '--[a-zA-Z0-9_-]+:[[:space:]]*#[0-9a-fA-F]{3,8}' "$CSS" | sort -u | head -40 || true
  echo '```'
  echo
  echo "## Brand/meta signals from the HTML itself"
  echo '```'
  grep -oE '<meta[^>]*theme-color[^>]*>' "$OUTDIR/raw/page.html" || true
  grep -oE '<meta[^>]*og:image[^>]*>' "$OUTDIR/raw/page.html" || true
  grep -oE '<link[^>]*rel="(shortcut )?icon"[^>]*>' "$OUTDIR/raw/page.html" || true
  echo '```'
} > "$TOKENS"

echo "==> Done."
echo "    Raw HTML/CSS: $OUTDIR/raw/"
echo "    Token summary: $TOKENS"
