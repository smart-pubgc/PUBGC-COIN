#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

PUBGCOIND=${PUBGCOIND:-$SRCDIR/pubgcoind}
PUBGCOINCLI=${PUBGCOINCLI:-$SRCDIR/pubgcoin-cli}
PUBGCOINTX=${PUBGCOINTX:-$SRCDIR/pubgcoin-tx}
PUBGCOINQT=${PUBGCOINQT:-$SRCDIR/qt/pubgcoin-qt}

[ ! -x $PUBGCOIND ] && echo "$PUBGCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
PUBGCVER=($($PUBGCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$PUBGCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $PUBGCOIND $PUBGCOINCLI $PUBGCOINTX $PUBGCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${PUBGCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${PUBGCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m