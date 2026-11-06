#!/usr/bin/env bash
# Build the front end the way the platform builds it, then search the files it
# serves for the two secrets. Nothing is simulated: this is vite, building.
set -uo pipefail
cd "$(dirname "$0")/app"

# The .env is what this lab is about, so it is shipped as an example and copied
# into place here. A repository whose article is "do not commit secrets" does
# not commit a file called .env, even one holding obvious placeholders.
cp -f .env.example .env

docker run --rm -v "$PWD":/app -w /app node:22-alpine \
  sh -c 'npm install --silent --no-audit --no-fund >/dev/null 2>&1 && npx --no-install vite build >/dev/null 2>&1'

PREFIXED=sk-lab-0000-this-is-not-a-real-key
PLAIN=sk-lab-1111-this-is-not-a-real-key-either

echo ""
echo "    the files the browser downloads:"
find dist -type f | sed 's|^dist/|      |' | sort

echo ""
echo "    which of those files contain each secret:"
for name in "VITE_PROVIDER_KEY" "PROVIDER_KEY (no prefix)"; do
  case "$name" in "VITE_"*) needle=$PREFIXED ;; *) needle=$PLAIN ;; esac
  files=$(grep -rl "$needle" dist 2>/dev/null | sed 's|^dist/||' | tr '\n' ' ')
  printf '      %-28s%s\n' "$name" "${files:-not in any shipped file}"
done

echo ""
echo "    and what the app does with each one:"
printf '      %-28s%s\n' "VITE_PROVIDER_KEY" "the request carries the key — the feature works"
printf '      %-28s%s\n' "PROVIDER_KEY (no prefix)" "undefined in the browser — the feature does not work"
echo ""
echo "    (vite 7.1.5, minify on, source maps on — the defaults a template ships with)"
