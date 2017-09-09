#!/bin/bash

# Extract metadata.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INDIR="$SCRIPTDIR/../data/original-data"
OUTDIR="$SCRIPTDIR/../data/metadata"

set -eu

mkdir -p "$OUTDIR"

for f in $(find "$INDIR" -maxdepth 1 -name '*.xml.gz' | sort -n); do
    b=$(basename "$f" .xml.gz)
    o="$OUTDIR/$b.json"
    if [[ -s "$o" && "$o" -nt "$f" ]]; then
	echo "Newer $o exists, skipping ..." >&2
    else
	echo "Extracting metadata from $f to $o ..." >&2
	python "$SCRIPTDIR/../extract.py" \
	       --metadata --no-title --no-abstract --json -o - "$f" > "$o"
	echo "Done extracting metadata from $f to $o ..." >&2
    fi
done
