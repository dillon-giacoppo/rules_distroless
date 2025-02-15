#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly bsdtar="$1"
readonly out="$2"
readonly package_path="$3"
readonly time="$4"
shift 4

# TODO: there must be a better way to manipulate tars!
# "$bsdtar" -cf  $out --posix --no-same-owner --options="" $@ "@$package_path"
# "$bsdtar" -cf to.mtree $@ --format=mtree --options '!gname,!uname,!sha1,!nlink' "@$package_path"
# "$bsdtar" --older "0" -Uf $out @to.mtree

tmp=$(mktemp -d)
"$bsdtar" -xf "$package_path" $@ -C "$tmp"
"$bsdtar" -cf - $@ --format=mtree --options '!gname,!uname,!sha1,!nlink,!time' "@$package_path" |
    sed 's/$/ time='"$time"'/' |
    "$bsdtar" --gzip --options 'gzip:!timestamp' -cf "$out" -C "$tmp/" @-
