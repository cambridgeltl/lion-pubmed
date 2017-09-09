#!/bin/bash

# Download source data.

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTDIR="$SCRIPTDIR/../data/original-data"

SOURCES="
ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline/
ftp://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles/
"

set -eu

mkdir -p "$OUTDIR"

for url in $SOURCES; do
    echo "Downloading from $url to $OUTDIR ..." >&2
    wget \
	--recursive \
	--no-parent \
	--no-clobber \
	--no-host-directories \
	--no-directories \
	--accept="*.xml.gz,*.xml.gz.md5" \
	--directory-prefix="$OUTDIR" \
	"$url"
    echo "Done downloading from $url to $OUTDIR ..." >&2
done    
