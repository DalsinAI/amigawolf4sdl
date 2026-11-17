#!/bin/sh
# The release archive, for Cradle's stove_build (target package): Wolf4SDL
# built with amiga/Makefile.amigaos on acsdl12 and acgame.library (acgame,
# acsdl12 and zlib fetched and built at pinned commits by
# package/acgame-deps.sh), then tools/make_package.py makes
# wolf3d-VERSION-68040.lha with its .sha256 and .readme: the Wolf3D drawer
# (the program and its GlowIcon, the ReadMe, the licences, and the acgame.library it was built against in Libs/), its
# icon, and beside them the Amiga Installer script Install-Wolf3D and its
# icon (package/installer/, made by amicradle scripts/port_installer.py
# from package/installer.json). The game's data is not in it. OUT also
# gets the drawer as it unpacks, as Wolf3D.tar (for a lab), and
# package.json. VERSION is package/VERSION. Nothing is published from here.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
OUT=${OUT:-"$ROOT/build-amiga-package"}
VERSION=$(cat "$HERE/VERSION")
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
BUILD=$(mktemp -d "${TMPDIR:-/tmp}/wolf3d-package.XXXXXX")
trap 'rm -rf "$BUILD"' EXIT INT TERM
cd "$ROOT"

ACSDL12=1
. "$HERE/acgame-deps.sh"

make -f amiga/Makefile.amigaos STOVE="$STOVE" NDK="$NDK" ACSDL="$ACSDL" ACSDLLIB="$ACSDLLIB" ACGAME="$ACGAME" ACGAMELIB="$ACGAMELIB" -j"${JOBS:-2}" > "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }
# One binary for every 68040 and 68060: -m68040 -msoft-float throughout (the
# game and acsdl12), no FPU instruction in their objects, the stove's fpuauto
# linked in.
{ sh "$HERE/soft-float.sh" "$STOVE" build/amigaos/wolf3d --log "$OUT/build-output.txt" --log "$OUT/acsdl12-output.txt" build/amigaos "$ACSDLLIB"; } > "$OUT/soft-float.txt" || { cat "$OUT/soft-float.txt"; exit 1; }
cat "$OUT/soft-float.txt"
cp build/amigaos/wolf3d "$BUILD/wolf3d"

# What the ReadMe and the check name: the program's SHA-256, the commit, the
# compiler and the commit's date (the archive's dates, so the same inputs
# make the same bytes).
python3 - "$BUILD" "$STOVE/bin/m68k-amigaos-gcc" "wolf3d" "$ACGAME_COMMIT" <<'PY'
import hashlib, json, subprocess, sys
from pathlib import Path
build, cc, exe, acgame = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
git = lambda *a: subprocess.run(["git", *a], capture_output=True, text=True).stdout.strip()
receipt = {
    "executable_sha256": hashlib.sha256((build / exe).read_bytes()).hexdigest(),
    "source_commit": git("rev-parse", "HEAD"),
    "compiler_release": subprocess.run([cc, "--version"], capture_output=True,
                                       text=True).stdout.splitlines()[0],
    "source_date_epoch": int(git("log", "-1", "--format=%ct") or 0),
    "acgame_commit": acgame,
    "acgame_library_sha256": hashlib.sha256((build / "acgame.library").read_bytes()).hexdigest(),
}
(build / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
PY
cp "$BUILD/receipt.json" "$OUT/receipt.json"
python3 "$ROOT/tools/make_package.py" --build "$BUILD" --version "$VERSION" --out "$OUT"
