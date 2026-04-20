#!/usr/bin/env bash
# Convert Swift code coverage (.profdata) into LCOV (SF/DA) format.
#
# Expects `swift test --enable-code-coverage` to have been run beforehand so
# that the profdata and xctest bundle exist under .build/.
#
# Output: coverage/lcov.info

set -euo pipefail

BUILD_DIR="${BUILD_DIR:-.build/debug}"
PROFDATA="${BUILD_DIR}/codecov/default.profdata"
OUT_DIR="coverage"
OUT_FILE="${OUT_DIR}/lcov.info"

if [[ ! -f "${PROFDATA}" ]]; then
  echo "error: ${PROFDATA} not found. Run 'swift test --enable-code-coverage' first." >&2
  exit 1
fi

# Auto-detect the test bundle (*.xctest) — bundle name depends on package name.
# -L follows symlinks because .build/debug is a symlink to arm64-apple-macosx/debug.
XCTEST_BUNDLE="$(find -L "${BUILD_DIR}" -maxdepth 1 -name '*.xctest' -print -quit)"
if [[ -z "${XCTEST_BUNDLE}" ]]; then
  echo "error: no *.xctest bundle found under ${BUILD_DIR}" >&2
  exit 1
fi

# Resolve the test binary: macOS keeps it under Contents/MacOS/, Linux puts it directly.
BUNDLE_NAME="$(basename "${XCTEST_BUNDLE}" .xctest)"
if [[ -f "${XCTEST_BUNDLE}/Contents/MacOS/${BUNDLE_NAME}" ]]; then
  BINARY="${XCTEST_BUNDLE}/Contents/MacOS/${BUNDLE_NAME}"
elif [[ -f "${XCTEST_BUNDLE}/${BUNDLE_NAME}" ]]; then
  BINARY="${XCTEST_BUNDLE}/${BUNDLE_NAME}"
else
  echo "error: test binary not found inside ${XCTEST_BUNDLE}" >&2
  exit 1
fi

# Pick llvm-cov: prefer xcrun (macOS) so the active toolchain is used.
if command -v xcrun >/dev/null 2>&1; then
  LLVM_COV=(xcrun llvm-cov)
elif command -v llvm-cov >/dev/null 2>&1; then
  LLVM_COV=(llvm-cov)
else
  echo "error: llvm-cov not found (need xcrun on macOS or llvm-cov on PATH)" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"

"${LLVM_COV[@]}" export \
  -format=lcov \
  -instr-profile="${PROFDATA}" \
  -ignore-filename-regex='(Tests|\.build)/' \
  "${BINARY}" \
  > "${OUT_FILE}"

echo "wrote ${OUT_FILE} ($(wc -l < "${OUT_FILE}" | tr -d ' ') lines)"
