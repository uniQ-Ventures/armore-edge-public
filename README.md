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
| iOS (App Store) | `release-ios.yml` | tag `v*` ⚠️ scaffold-stage¹ |
| Android (Play) | `release-android.yml` | tag `v*` ⚠️ scaffold-stage¹ |

> ¹ **iOS/Android: the pipeline is wired, a shippable app is not (yet).** The mobile
> apps in `armore-edge-mobile` are early **scaffold** (`PlaceholderScaffold`, tab/settings
> shells, core-binding smoke), blocked on SDK gaps (#41 binding gate, `peer_id()` for
> pairing). A tagged release will **not** produce a store-ready iOS/Android build until
> those land — this is beyond the signing-cert TODO below, which alone would not make a
> scaffold shippable. **macOS/Windows are the real release targets today.** (Per `PRD.md`
> #229: no unqualified mobile claims in public copy.)

**TODO (operator, #1162):** wire signing certs/secrets (Apple notarization, Windows code-sign,
Play upload key) — these are deploy-cred items only the operator provisions.
