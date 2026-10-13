#!/usr/bin/env bash
#
# Armore Edge — verify a release artifact's Sigstore keyless signature.
#
# Every release asset (CLI binaries, SDK addons, SBOMs, TUF metadata tarball)
# is signed in CI with `cosign sign-blob` via the GitHub Actions OIDC keyless
# flow — no long-lived key exists. The signature + certificate + Rekor
# transparency-log proof are shipped as a single `<asset>.sigstore.json`
# bundle next to each asset.
#
# This script verifies that a downloaded artifact:
#   1. matches the signature in its bundle (any byte flip fails),
#   2. was signed by THIS repo's release workflow (certificate identity is
#      pinned to the workflow file + a v* tag or main), and
#   3. the signing certificate came from GitHub's OIDC issuer.
#
# Usage:
#   scripts/verify-release.sh <artifact> [bundle]
#     bundle defaults to <artifact>.sigstore.json
#
# Example (auditor flow):
#   gh release download v0.1.0 -R uniQ-Ventures/armore-edge \
#       -p 'armore-edge-cli-linux-x86_64*'
#   scripts/verify-release.sh armore-edge-cli-linux-x86_64
#
# Overrides (mainly for the CI round-trip test, which signs under the ci.yml
# workflow identity rather than release.yml):
#   VERIFY_REPO             owner/repo            (default uniQ-Ventures/armore-edge)
#   VERIFY_IDENTITY_REGEXP  full identity regexp  (default: this repo's release.yml
#                                                  at refs/tags/v* or refs/heads/main)
#   VERIFY_OIDC_ISSUER      OIDC issuer URL       (default: GitHub Actions)
#
# ─────────────────────────────────────────────────────────────────────────────
# NOTE FOR PUBLIC USERS — WHY THE SIGNER IS A REPO YOU CANNOT SEE.
#
# The identity below names `armore-edge-internal`, which is PRIVATE and returns
# 404 to you. That is expected and it does not weaken the check: cosign verifies
# the Fulcio CERTIFICATE embedded in the bundle plus its Rekor transparency-log
# entry. It never contacts the signing repo, and you do not need access to it.
# What you are proving is "these bytes were signed by that workflow on that ref",
# which is a statement about the certificate, not about your permissions.
#
# ⚠️ You are trusting us on one thing: that the named repo is really ours.
# If that is not good enough for you, the cheaper and fully independent check is
# the sha512 in the signed update manifest — see the README. It needs no extra
# tooling and no trust in a repository name.
# ─────────────────────────────────────────────────────────────────────────────

# Requires cosign >= 2.4 (bundle format support); tested with cosign 3.x.
# Verification is offline-ish: the bundle embeds the certificate and the Rekor
# log entry, so no per-artifact network lookup is needed — cosign only
# refreshes the cached Sigstore trusted root (TUF) if it is stale.

set -euo pipefail

die() { echo "verify-release: ERROR: $*" >&2; exit 1; }

ARTIFACT="${1:-}"
[[ -n "$ARTIFACT" ]] || die "usage: $0 <artifact> [bundle]"
[[ -f "$ARTIFACT" ]] || die "artifact not found: $ARTIFACT"

BUNDLE="${2:-${ARTIFACT}.sigstore.json}"
[[ -f "$BUNDLE" ]] || die "bundle not found: $BUNDLE (download the .sigstore.json asset next to the artifact)"

command -v cosign >/dev/null 2>&1 || die "cosign not installed (https://docs.sigstore.dev/cosign/system_config/installation/)"

# 🔴 BOTH VALUES BELOW WERE WRONG, AND THE SCRIPT FAILED ON EVERY REAL ARTIFACT (2026-10-13).
#
# Read out of the Fulcio certificate in a SHIPPED v1.0.10 bundle — not inferred:
#   https://github.com/uniQ-Ventures/armore-edge-internal/.github/workflows/release.yml
#     @refs/heads/integration/v2.0
#
# Against that, the old defaults failed twice over:
#   repo  was `armore-edge`              — the signing repo is `armore-edge-internal`
#   ref   allowed `tags/v*|heads/main`   — signing happens on `heads/integration/v2.0`,
#         which is ALSO not matchable by a naive `heads/[^/]+` because it contains a slash.
#
# ⚠️ WHY THIS MATTERED MORE THAN A BROKEN SCRIPT. The failure mode is not "command errors".
# cosign prints *"none of the expected identities matched what was in the certificate"* —
# which to a reader following our own published verify instructions reads as TAMPERING.
# We shipped a supply-chain story whose verification step accused our own artifacts.
# Reproduced before this fix: exit 1 on Armore-Edge-1.0.10-amd64.deb with that exact error.
#
# 🔴 THIS LIST IS A SECURITY CONTROL, NOT A CONVENIENCE. It is what stops a signature made by
# some OTHER workflow, branch or fork from verifying. Widen it only to a ref that legitimately
# signs releases, and never to a bare wildcard. `integration/v2.0` is enumerated literally
# rather than as a pattern, so a future `heads/anything` does not silently become acceptable.
#
# ⚪ `heads/main` is kept for artifacts signed before the trunk moved — dropping it would make
# older releases unverifiable, which is a different kind of false alarm.
REPO="${VERIFY_REPO:-uniQ-Ventures/armore-edge-internal}"
# The Fulcio certificate's SAN for a GitHub Actions keyless signature is
#   https://github.com/<owner>/<repo>/.github/workflows/<file>@<ref>
# Releases are signed by release.yml on a v* tag push, or by workflow_dispatch on the trunk
# (`integration/v2.0`) — anything else is NOT a legitimate release signature.
DEFAULT_IDENTITY_REGEXP="^https://github.com/${REPO}/\.github/workflows/release\.yml@refs/(tags/v[^/]+|heads/main|heads/integration/v2\.0)$"
IDENTITY_REGEXP="${VERIFY_IDENTITY_REGEXP:-$DEFAULT_IDENTITY_REGEXP}"
OIDC_ISSUER="${VERIFY_OIDC_ISSUER:-https://token.actions.githubusercontent.com}"

echo "verify-release: artifact : $ARTIFACT"
echo "verify-release: bundle   : $BUNDLE"
echo "verify-release: identity : $IDENTITY_REGEXP"
echo "verify-release: issuer   : $OIDC_ISSUER"

cosign verify-blob \
    --bundle "$BUNDLE" \
    --certificate-identity-regexp "$IDENTITY_REGEXP" \
    --certificate-oidc-issuer "$OIDC_ISSUER" \
    "$ARTIFACT"

echo "verify-release: OK — signature, signer identity, and transparency-log entry all check out."
