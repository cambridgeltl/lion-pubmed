#!/usr/bin/env python

# Get PMIDs and publication dates from JSON metadata.

from __future__ import print_function

import os
import sys
import re
import logging
import codecs

try:
    import ujson as json
except ImportError:
    import json

logging.basicConfig()
logger = logging.getLogger('pubdates')
debug, info, warn, error = logger.debug, logger.info, logger.warn, logger.error


def argparser():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-v', '--verbose', default=False, action='store_true',
                    help='Verbose output')
    ap.add_argument('-y', '--year-only', default=False, action='store_true',
                    help='Only output publication year')
    ap.add_argument('files', metavar='FILE', nargs='+',
                    help='Input metadata files')
    return ap


def read_pubdates(fn, id_to_pubdates=None):
    if id_to_pubdates is None:
        id_to_pubdates = {}

    info('reading publication dates from {}'.format(os.path.basename(fn)))
    with open(fn) as f:
        data = json.load(f)
    for i, d in enumerate(data, start=1):
        id_, pubdate = d['id'], d['pubdate']
        if id_ not in id_to_pubdates:
            id_to_pubdates[id_] = []
        id_to_pubdates[id_].append(pubdate)
    info('read {} publication dates from {}'.format(i, os.path.basename(fn)))
    return id_to_pubdates


def get_pubyears(id_to_pubdates):
    for id_ in id_to_pubdates.keys():
        pubyears = []
        for date in id_to_pubdates[id_]:
            orig = date
            # resolve approximate dates such as "Summer 2017"
            date = re.sub(r'^(?:spring|summer|autumn|fall|winter)\s*', '',
                          date, flags=re.I)
            # assume initial four digits are year
            date = date.replace('Fall ', '')
            m = re.match(r'^([0-9]{4})\b', date)
            if not m:
                error(u'Failed to parse year for {} from "{}"'.format(
                    id_, orig))
            else:
                pubyears.append(m.group(1))
        if pubyears:
            id_to_pubdates[id_] = pubyears
        else:
            error(u'No valid year for {}: {}'.format(id_, id_to_pubdates[id_]))
    return id_to_pubdates


def uniq(seq):
    useq, seen = [], set()
    for i in seq:
        if i in seen:
            continue
        seen.add(i)
        useq.append(i)
    return useq


def resolve_repeated(id_to_pubdates):
    id_to_pubdate = {}
    for id_, pubdates in id_to_pubdates.iteritems():
        pubdates = uniq(pubdates)
        if len(pubdates) == 1:
            id_to_pubdate[id_] = pubdates[0]
        else:
            choice = sorted(pubdates)[0]
            warn('multiple pubdates for {} ({}), using {}'.format(
                id_, ', '.join(pubdates), choice))
            id_to_pubdate[id_] = choice
    return id_to_pubdate


def main(argv):
    args = argparser().parse_args(argv[1:])
    if args.verbose:
        logger.setLevel(logging.INFO)

    id_to_pubdates = None
    for fn in args.files:
        id_to_pubdates = read_pubdates(fn, id_to_pubdates)

    if args.year_only:
        id_to_pubdates = get_pubyears(id_to_pubdates)
    id_to_pubdate = resolve_repeated(id_to_pubdates)

    utf8out = codecs.getwriter('utf-8')(sys.stdout)
    for id_, pubdate in sorted(id_to_pubdate.items(), key=lambda i: int(i[0])):
        print(u'{}\t{}'.format(id_, pubdate), file=utf8out)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
