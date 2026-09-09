#!/usr/bin/bash
set -euo pipefail
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cd "$root"
[[ $(node -p 'process.versions.node.split(".")[0]') == 24 ]] || {
  echo 'Use Node 24 on PATH before building.' >&2; exit 1;
}
for tool in npm makepkg python3 tar sha256sum; do command -v "$tool" >/dev/null; done
mkdir -p "$root/main/dist"
out=$(mktemp -d "$root/main/dist/arch-build.XXXXXX")
trap 'echo "Build directory: $out"' EXIT

# Include current source changes, but never dependencies, build outputs or .git.
# Only these application/packaging paths are eligible for the source snapshot.
git ls-files --cached --others --exclude-standard -z -- \
  main renderer ipc LICENSE packaging/arch > "$out/source-files"
tar --null --verbatim-files-from --files-from="$out/source-files" \
  --transform='s,^,source/,' -czf "$out/source.tar.gz"
digest=$(sha256sum "$out/source.tar.gz" | cut -d ' ' -f1)
version=$(node -p 'require("./main/package.json").version')
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo 'Expected a stable x.y.z version; adjust Arch version mapping first.' >&2; exit 1;
}
python3 - "$root/packaging/arch/PKGBUILD" "$out/PKGBUILD" "$version" "$digest" <<'PY'
import pathlib, sys
source, target, version, digest = sys.argv[1:]
pathlib.Path(target).write_text(pathlib.Path(source).read_text()
    .replace('@VERSION@', version).replace('@SHA256@', digest))
PY
{
  git rev-parse HEAD
  git status --short
  node --version
  npm --version
  sha256sum "$out/source.tar.gz"
} > "$out/provenance.txt"
cd "$out"
makepkg --cleanbuild
