#!/usr/bin/env bash
# Builds assets/banner.svg.
#
# Nothing here is drawn. The bnuuy is the geometry from chiwavisualkit/src/emotes.py,
# coordinate for coordinate. The palette, the type roles and the layout are the ones
# in the brand manual (chiwavisualkit/src/manual.py): noir ground, grain at 5.5%,
# Playfair Display uppercase for the name, one vinho rule, Inter for the lema row.
#
# Vetoes respected: no gradient, no glow, no pure white, no corner ornament, no arch.
#
# Fonts are pulled from Google Fonts as per-glyph subsets and inlined as base64,
# because an SVG loaded as <img> on GitHub cannot fetch anything.
set -euo pipefail
cd "$(dirname "$0")"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

sub() { # family, text, outfile
  local css="$tmp/c.css"
  curl -sS -A "$UA" "https://fonts.googleapis.com/css2?family=$1&text=$2" -o "$css"
  curl -sS -A "$UA" "$(grep -o 'https://fonts.gstatic.com/[^)]*' "$css")" -o "$tmp/$3"
  base64 -w0 "$tmp/$3"
}

PD=$(sub "Playfair+Display:wght@500" "BNUYCODE"                             pd.woff2)
IN=$(sub "Inter:wght@400"            "ABCDEFGHIJKLMNOPQRSTUVWXYZ%20.%2F"    in.woff2)
SE=$(sub "Noto+Sans+Symbols+2"       "%E2%9C%A6"                            st.woff2)

cat > banner.svg <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 384" width="1200" height="384" role="img" aria-label="BNUUYCODE - Java, Python, SQLite">
<defs>
<style>
@font-face{font-family:'PD';font-weight:500;src:url(data:font/woff2;base64,$PD) format('woff2')}
@font-face{font-family:'IN';font-weight:400;src:url(data:font/woff2;base64,$IN) format('woff2')}
@font-face{font-family:'SEL';font-weight:400;src:url(data:font/woff2;base64,$SE) format('woff2')}
</style>
<filter id="grao" x="0" y="0" width="100%" height="100%">
<feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="3"/>
</filter>
</defs>

<rect width="1200" height="384" fill="#141414"/>
<rect width="1200" height="384" filter="url(#grao)" opacity="0.055"/>

<!-- bnuuy - chiwavisualkit/src/emotes.py, unaltered -->
<g transform="translate(530 31.5) scale(1.25)" fill="#EFEFEF">
<ellipse cx="42" cy="36" rx="10.5" ry="26" transform="rotate(-12 42 36)"/>
<ellipse cx="70" cy="36" rx="10.5" ry="26" transform="rotate(12 70 36)"/>
<ellipse cx="56" cy="74" rx="27" ry="23"/>
<circle cx="46" cy="71" r="3.8" fill="#1B1B1B"/><circle cx="66" cy="71" r="3.8" fill="#1B1B1B"/>
<path d="M51 81l5 4 5-4" fill="none" stroke="#1B1B1B" stroke-width="4.2" stroke-linecap="round"/>
</g>

<text x="595" y="246" text-anchor="middle" font-family="'PD',Georgia,serif" font-weight="500"
      font-size="84" letter-spacing="10.08" fill="#EFEFEF">BNUUYCODE</text>

<rect x="500" y="282" width="200" height="1" fill="#8E3A48"/>

<text x="597" y="328" text-anchor="middle" font-family="'IN',system-ui,sans-serif" font-weight="400"
      font-size="15" letter-spacing="6.3" fill="#7A7A7A">JAVA<tspan
      font-family="'SEL',serif" font-size="11" fill="#8E3A48" dx="10">&#10022;</tspan><tspan dx="10">PYTHON</tspan><tspan
      font-family="'SEL',serif" font-size="11" fill="#8E3A48" dx="10">&#10022;</tspan><tspan fill="#7A7A7A" dx="10">SQLITE</tspan></text>
</svg>
SVG
printf 'banner.svg: %s bytes\n' "$(wc -c < banner.svg)"
