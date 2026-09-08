#!/bin/sh
set -eu

base_url="${BOOMBOX_DOWNLOAD_BASE_URL:-https://github.com/KonstantCloud/boombox/releases/latest/download}"
install_dir="${BOOMBOX_INSTALL_DIR:-${HOME}/.local/bin}"

fail() {
  printf '%s\n' "boombox installer: $*" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || fail 'curl is required'
command -v tar >/dev/null 2>&1 || fail 'tar is required'

os=$(uname -s 2>/dev/null || true)
arch=$(uname -m 2>/dev/null || true)
case "${os}:${arch}" in
  Linux:x86_64|Linux:amd64) artifact='boombox-x86_64-unknown-linux-gnu.tar.gz' ;;
  Linux:aarch64|Linux:arm64) artifact='boombox-aarch64-unknown-linux-gnu.tar.gz' ;;
  Darwin:x86_64) artifact='boombox-x86_64-apple-darwin.tar.gz' ;;
  Darwin:arm64|Darwin:aarch64) artifact='boombox-aarch64-apple-darwin.tar.gz' ;;
  *) fail "unsupported platform ${os:-unknown}/${arch:-unknown}" ;;
esac

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/boombox.XXXXXX")
install_stage=''
cleanup() {
  rm -rf "$tmp_dir"
  [ -z "$install_stage" ] || rm -rf "$install_stage"
}
trap cleanup EXIT HUP INT TERM
archive="$tmp_dir/boombox.tar.gz"

printf '%s\n' "boombox installer: downloading ${artifact}"
curl -fsSL --retry 3 -o "$archive" "${base_url}/${artifact}"
expected=$(curl -fsSL --retry 3 "${base_url}/${artifact}.sha256" | awk 'NR == 1 { print $1 }')
[ -n "$expected" ] || fail 'release checksum is empty'

if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$archive" | awk '{ print $1 }')
elif command -v shasum >/dev/null 2>&1; then
  actual=$(shasum -a 256 "$archive" | awk '{ print $1 }')
else
  fail 'sha256sum or shasum is required'
fi
[ "$actual" = "$expected" ] || fail 'release checksum did not match downloaded bytes'

mkdir -p "$tmp_dir/unpack" "$install_dir"
tar -xzf "$archive" -C "$tmp_dir/unpack"
set -- "$tmp_dir"/unpack/boombox-*/boombox
[ "$#" -eq 1 ] && [ -f "$1" ] || fail 'release archive did not contain one boombox executable'
bundle_dir=$(dirname "$1")
[ -f "$bundle_dir/bundle.json" ] && [ -f "$bundle_dir/libexec/node" ] || fail 'release archive is missing the bundled runtime'
install_dir=$(cd "$install_dir" && pwd -P)
mkdir -p "$install_dir/.boombox"
candidate=$(mktemp -d "$install_dir/.boombox/release.XXXXXX")
install_stage="$candidate"
cp -R "$bundle_dir/." "$candidate/"
# Test the entire candidate before switching the stable command. Old releases
# remain available for rollback and existing project MCP references.
"$candidate/boombox" --version
"$candidate/boombox" paths --json >/dev/null
link_stage=$(mktemp -d "$install_dir/.boombox-link.XXXXXX")
ln -s "$candidate/boombox" "$link_stage/boombox"
mv -f "$link_stage/boombox" "$install_dir/boombox"
rmdir "$link_stage"
install_stage=''

printf '\n%s\n' 'Boombox installed:'
"$install_dir/boombox" --version
case ":${PATH}:" in
  *":${install_dir}:"*) ;;
  *) printf '%s\n' "Add ${install_dir} to PATH, then open a new shell." ;;
esac
printf '%s\n' 'Next: boombox project init . --client claude --client codex'
