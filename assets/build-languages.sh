#!/usr/bin/env bash
# Builds assets/languages.svg from the language byte counts GitHub reports for
# every non-fork public repo on the account. No third-party service: the data
# comes from the GitHub API and the drawing happens here.
#
# Palette and type roles from the chiwavisualkit brand manual. Vinho marks the
# dominant language only - accent that means something, not decoration.
set -euo pipefail
cd "$(dirname "$0")"
USER=${1:-bnuuyCode}
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

IN=$(curl -sS -A "$UA" "https://fonts.googleapis.com/css2?family=Inter:wght@400&text=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789%20.%25" -o "$tmp/c.css" \
     && curl -sS -A "$UA" "$(grep -o 'https://fonts.gstatic.com/[^)]*' "$tmp/c.css")" -o "$tmp/in.woff2" \
     && base64 -w0 "$tmp/in.woff2")

for r in $(gh api "users/$USER/repos?per_page=100&type=owner" --jq '.[] | select(.fork==false) | .name'); do
  gh api "repos/$USER/$r/languages" --jq 'to_entries[] | "\(.key) \(.value)"'
done | awk '{a[$1]+=$2} END{for(k in a) print a[k], k}' | sort -rn | head -6 > "$tmp/lang"

awk -v IN="$IN" '
{ b[NR]=$1; n[NR]=toupper($2); t+=$1 }
END{
  rows=NR; h=64+rows*46
  printf "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 620 %d\" width=\"620\" height=\"%d\" role=\"img\" aria-label=\"languages by bytes committed\">\n", h, h
  printf "<defs><style>@font-face{font-family:'\''IN'\'';font-weight:400;src:url(data:font/woff2;base64,%s) format('\''woff2'\'')}</style></defs>\n", IN
  printf "<rect width=\"620\" height=\"%d\" fill=\"#141414\"/>\n", h
  printf "<text x=\"0\" y=\"22\" font-family=\"'\''IN'\'',system-ui,sans-serif\" font-size=\"11\" letter-spacing=\"3.7\" fill=\"#5E5E5E\">LANGUAGES BY BYTES COMMITTED</text>\n"
  for(i=1;i<=rows;i++){
    y=64+(i-1)*46; p=b[i]*100/t; w=p*6.2
    col=(i==1)?"#8E3A48":"#B4B4B4"
    printf "<text x=\"0\" y=\"%d\" font-family=\"'\''IN'\'',system-ui,sans-serif\" font-size=\"13\" letter-spacing=\"3.1\" fill=\"#EFEFEF\">%s</text>\n", y, n[i]
    printf "<text x=\"620\" y=\"%d\" text-anchor=\"end\" font-family=\"'\''IN'\'',system-ui,sans-serif\" font-size=\"13\" fill=\"#5E5E5E\">%.1f%%</text>\n", y, p
    printf "<rect x=\"0\" y=\"%d\" width=\"620\" height=\"2\" fill=\"#2E2E2E\"/>\n", y+12
    printf "<rect x=\"0\" y=\"%d\" width=\"%.1f\" height=\"2\" fill=\"%s\"/>\n", y+12, w, col
  }
  print "</svg>"
}' "$tmp/lang" > languages.svg

printf 'languages.svg: %s bytes\n' "$(wc -c < languages.svg)"
awk '{printf "  %-12s %s bytes\n", $2, $1}' "$tmp/lang"
