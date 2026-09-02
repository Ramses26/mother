#!/bin/sh
# Render apprise.yml.template -> apprise.yml, substituting real values from the
# environment. Run by the `apprise-init` container before apprise starts.
#
# Exists because Apprise does not expand ${VAR} inside its YAML config, and
# apprise.yml.template is git-tracked so it cannot hold the real bot token.
set -eu

SRC=/config/apprise.yml.template
DST=/config/apprise.yml

[ -f "$SRC" ] || { echo "render: $SRC missing"; exit 1; }

missing=""
for v in TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID UPGRADERR_TELEGRAM_CHAT_ID \
         CURATORR_TELEGRAM_CHAT_ID MOTHER_NOTIFICATIONS_CHAT_ID; do
    eval "val=\${$v:-}"
    [ -n "$val" ] || missing="$missing $v"
done
if [ -n "$missing" ]; then
    echo "render: FATAL, unset in the container environment:$missing"
    echo "render: add them to the apprise-init service's environment in docker-compose.yml"
    exit 1
fi

# Use a non-/ delimiter: tokens contain ':' and chat ids start with '-'.
sed -e "s|\${TELEGRAM_BOT_TOKEN}|${TELEGRAM_BOT_TOKEN}|g" \
    -e "s|\${TELEGRAM_CHAT_ID}|${TELEGRAM_CHAT_ID}|g" \
    -e "s|\${UPGRADERR_TELEGRAM_CHAT_ID}|${UPGRADERR_TELEGRAM_CHAT_ID}|g" \
    -e "s|\${CURATORR_TELEGRAM_CHAT_ID}|${CURATORR_TELEGRAM_CHAT_ID}|g" \
    -e "s|\${MOTHER_NOTIFICATIONS_CHAT_ID}|${MOTHER_NOTIFICATIONS_CHAT_ID}|g" \
    "$SRC" > "$DST"

# Only check real config lines -- the template's own comments legitimately
# mention ${VAR} while explaining why this render step exists.
if grep -v '^[[:space:]]*#' "$DST" | grep -q '\${'; then
    echo "render: FATAL, unsubstituted placeholders remain:"
    grep -vn '^[[:space:]]*#' "$DST" | grep '\${'
    rm -f "$DST"
    exit 1
fi
chmod 600 "$DST"
echo "render: wrote $DST ($(grep -c 'tgram://' "$DST") telegram targets)"
