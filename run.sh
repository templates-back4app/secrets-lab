#!/usr/bin/env bash
# Where a secret ends up, and what removing it does.
#
#   ./run.sh
#
# Needs Docker and Node 22.
set -uo pipefail
cd "$(dirname "$0")"

# Fail here rather than three minutes from now with an empty result.
docker info >/dev/null 2>&1 || {
  echo ""
  echo "  Docker is not running. Start Docker Desktop (or your daemon) and run this again."
  echo ""
  exit 1
}
echo ""
echo "  [1/3] WHAT ENDS UP IN THE FILES THE BROWSER DOWNLOADS"
./frontend.sh
echo "  [2/3] WHAT DELETING THE COMMIT REMOVES"
./history.sh
echo "  [3/3] WHETHER REMOVING IT ENDS THE EXPOSURE"
node rotate.mjs
