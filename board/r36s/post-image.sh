#!/usr/bin/env bash
set -ex

cp board/r36s/image.its "${BINARIES_DIR}"
(cd "${BINARIES_DIR}" && mkimage -f image.its image.itb && rm image.its)
support/scripts/genimage.sh -c board/r36s/genimage.cfg
