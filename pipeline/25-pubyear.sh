#!/bin/bash

# Get PMID-pubyear pairs from metadata.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INDIR="$SCRIPTDIR/../data/metadata"
OUTDIR="$SCRIPTDIR/../data"

set -eu

mkdir -p "$OUTDIR"

n=$(ls -t "$INDIR"/*.json | head -n 1)
o="$OUTDIR/pubdates.tsv"

if [[ -s "$o" && "$o" -nt "$n" ]]; then
    echo "Newer $o exists, skipping ..." >&2
else
    echo "Extracting pubdates from $INDIR to $o ..." >&2
    python "$SCRIPTDIR/../scripts/getpubdates.py" \
	   -y -v "$INDIR"/*.json > "$o"
    echo "Done extracting pubdates from $INDIR to $o ..." >&2
fi
