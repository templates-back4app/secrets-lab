#!/usr/bin/env bash
# Where a secret ends up, and what removing it does.
#
#   ./run.sh
#
# Needs Docker and Node 22.
set -uo pipefail
cd "$(dirname "$0")"
echo ""
echo "  [1/3] WHAT ENDS UP IN THE FILES THE BROWSER DOWNLOADS"
./frontend.sh
echo "  [2/3] WHAT DELETING THE COMMIT REMOVES"
./history.sh
echo "  [3/3] WHETHER REMOVING IT ENDS THE EXPOSURE"
node rotate.mjs
