#!/usr/bin/env bash
# Fetches the private application code with a read-only deploy key (CS_DEPLOY_KEY_B64) and installs it under ./app.
set -euo pipefail
umask 077
KEY="$(mktemp)"
cleanup() { rm -f "$KEY"; }
trap cleanup EXIT INT TERM
printf '%s' "$CS_DEPLOY_KEY_B64" | base64 -d > "$KEY"
rm -rf app app.partial
GIT_SSH_COMMAND="ssh -i $KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" git clone --depth 1 --branch main "git@github.com:${CS_APP_REPO}.git" app.partial
( cd app.partial/core && npm install --omit=dev --no-audit --no-fund )
test -f app.partial/core/server.js && test -d app.partial/core/node_modules/pg
git -C app.partial rev-parse --short HEAD > app.partial/REVISION
mv app.partial app
echo "application revision $(cat app/REVISION)"
