#!/bin/bash

# Verify md5 checksums.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "$0")

DATADIR="$SCRIPTDIR/../data/original-data"
STATUSDIR="$SCRIPTDIR/../data/status"

set -eu

mkdir -p "$STATUSDIR"

for f in "$DATADIR"/*.md5; do
    # stripping ".md5" gives name of file that md5sum is for
    b="${f%.md5}"
    s="$STATUSDIR"/$(basename "$f" .md5).log
    if [ -e "$s" ] && [ "$s" -nt "$f" ] && \
	   grep -qF "Done $SCRIPTNAME" "$s"; then
	echo "$SCRIPTNAME done for $b ($s), skipping ..." >&2
    else
	ref=$(cat "$f" | perl -pe 's/^MD5\s*\(.*?\)\s*=\s*//')
	val=$(md5sum < "$b" | perl -pe 's/ +- *$//')
	echo -n "Checking md5sum $f for $b ... " >&2
	if [[ "$ref" != "$val" ]]; then
	    echo $'\n'"ERROR: md5sum mismatch for $b: $ref vs $val" >&2
	    exit 1
	else
	    echo "OK" >&2
	fi
	echo "Done $SCRIPTNAME" > "$s"
    fi
done
