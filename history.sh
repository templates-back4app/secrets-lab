#!/usr/bin/env bash
# You committed a key, noticed, and deleted it. Is it gone?
#
# A throwaway repository, built and destroyed here, so nothing touches yours.
set -uo pipefail
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
KEY=sk-lab-2222-committed-by-mistake

git init -q .
git config user.email dev@example.invalid
git config user.name "A Developer"

printf 'const key = "%s";\n' "$KEY" > config.js
git add . && git commit -qm "add the integration"

printf 'const key = process.env.PROVIDER_KEY;\n' > config.js
git add . && git commit -qm "move the key out of the code"

echo ""
# grep -q would exit on the first match, kill `git log` with SIGPIPE and — under
# pipefail — turn a hit into a reported miss. Count instead.
yesno() { [ "$1" -gt 0 ] && echo yes || echo no; }
printf '    %-50s%s\n' "the key is in the files as they stand now:" "$(yesno "$(grep -rc "$KEY" --include='*.js' . | awk -F: '{t+=$2} END{print t+0}')")"
printf '    %-50s%s\n' "the key is in the repository's history:" "$(yesno "$(git log -p --all | grep -c "$KEY")")"

BLOB=$(git rev-list --objects --all | awk '{print $1}' | while read -r o; do
  [ "$(git cat-file -t "$o" 2>/dev/null)" = blob ] && git cat-file -p "$o" 2>/dev/null | grep -q "$KEY" && { echo "$o"; break; }
done)
printf '    %-50s%s\n' "retrievable by object id, after the deletion:" "$( [ -n "$BLOB" ] && echo "yes — git cat-file -p ${BLOB:0:12}" || echo no )"
echo ""
echo "    what the deleting commit actually did:"
echo "      it added a new version of the file. The old version is still an object"
echo "      in the repository, and a clone or a fork carries every one of them."
