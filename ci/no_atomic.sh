#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")"/..

# Update the list of targets that do not support atomic/CAS operations.
#
# Usage:
#    ./ci/no_atomic.sh

file="valuable/no_atomic.rs"

no_atomic_cas=()
no_atomic_64=()
no_atomic=()
for target in $(rustc --print target-list); do
    target_spec=$(rustc --print target-spec-json -Z unstable-options --target "${target}")
    res=$(jq <<<"${target_spec}" -r 'select(."atomic-cas" == false)')
    [[ -z "${res}" ]] || no_atomic_cas+=("${target}")
    max_atomic_width=$(jq <<<"${target_spec}" -r '."max-atomic-width"')
    min_atomic_width=$(jq <<<"${target_spec}" -r '."min-atomic-width"')
    case "${max_atomic_width}" in
        # It is not clear exactly what `"max-atomic-width" == null` means, but they
        # actually seem to have the same max-atomic-width as the target-pointer-width.
        # The targets currently included in this group are "mipsel-sony-psp",
        # "thumbv4t-none-eabi", "thumbv6m-none-eabi", all of which are
        # `"target-pointer-width" == "32"`, so assuming them `"max-atomic-width" == 32`
        # for now.
        32 | null) no_atomic_64+=("${target}") ;;
        # `"max-atomic-width" == 0` means that atomic is not supported at all.
        # We do not have a cfg for targets with {8,16}-bit atomic only, so
        # for now we treat them the same as targets that do not support atomic.
        0 | 8 | 16) no_atomic+=("${target}") ;;
        64 | 128) ;;
        *) exit 1 ;;
    esac
    case "${min_atomic_width}" in
        8 | null)  ;;
        *) no_atomic+=("${target}") ;;
    esac
done

cat >"${file}" <<EOF
// This file is @generated by $(basename "$0").
// It is not intended for manual editing.

const NO_ATOMIC_CAS: &[&str] = &[
EOF
for target in "${no_atomic_cas[@]}"; do
    echo "    \"${target}\"," >>"${file}"
done
cat >>"${file}" <<EOF
];

const NO_ATOMIC_64: &[&str] = &[
EOF
for target in "${no_atomic_64[@]}"; do
    echo "    \"${target}\"," >>"${file}"
done
cat >>"${file}" <<EOF
];

const NO_ATOMIC: &[&str] = &[
EOF
for target in "${no_atomic[@]}"; do
    echo "    \"${target}\"," >>"${file}"
done
cat >>"${file}" <<EOF
];
EOF
