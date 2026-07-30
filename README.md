# armore-edge — releases

The public release face for armore-edge. **Clean history, release artifacts + pipelines only** —
no dev churn (that lives in `armore-edge-internal`).

- Tagged releases (`vX.Y.Z`) trigger the platform pipelines below.
- Write is via **PR only**; direct pushes to `main` are blocked.
- Access: owner + arunabha (write), Mohit (read). Interns do not get write here.

> Stays **private** until the public-flip gate clears: SecAgg scrub (#1040) + FL provisionals
> filed (#783). Do not make public before then — absolute-novelty forfeiture risk.

## Pipelines (`.github/workflows/`)
| Platform | Workflow | Trigger |
|---|---|---|
| macOS (.dmg) | `release-macos.yml` | tag `v*` |
| Windows (.exe/.msi) | `release-windows.yml` | tag `v*` |
| iOS (App Store) | `release-ios.yml` | tag `v*` |
| Android (Play) | `release-android.yml` | tag `v*` |

**TODO (operator, #1162):** wire signing certs/secrets (Apple notarization, Windows code-sign,
Play upload key) — these are deploy-cred items only the operator provisions.
