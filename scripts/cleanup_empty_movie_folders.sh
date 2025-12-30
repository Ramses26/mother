#!/usr/bin/env bash
set -euo pipefail

MOVIE_ROOT="${MOVIE_ROOT:-/mnt/synology/rs-movies}"
LOG_FILE="${LOG_FILE:-$HOME/empty_movie_folders.log}"

if [[ ! -d "$MOVIE_ROOT" ]]; then
  echo "Movie root $MOVIE_ROOT does not exist or is not mounted." >&2
  exit 1
fi

echo "Scanning for empty folders under $MOVIE_ROOT ..."
while read -r dir; do
  echo "$dir"
done < <(find "$MOVIE_ROOT" -mindepth 1 -type d -empty | sort) | tee "$LOG_FILE"

echo
echo "Total empty folders: $(wc -l < "$LOG_FILE")"
echo "A list has been saved to $LOG_FILE"
echo
read -rp "Delete these folders? (yes/no): " answer
case "$answer" in
  yes|y|Y)
    echo "Deleting folders..."
    xargs -0 -I{} rm -rf "{}" < <(tr '\n' '\0' < "$LOG_FILE")
    echo "Done."
    ;;
  *)
    echo "No folders were deleted."
    ;;
esac
