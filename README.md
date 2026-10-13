# Armore Edge — public releases

Signed builds of **Armore Edge**, the desktop app that answers questions over your own
files with the reasoning running on your machine.

> ⚠️ **This is a release face, not the source tree.** It holds releases, a contributing
> guide, the release workflows and the verification script — **no application code.**
> Development happens in a separate private repository. Do not read this repo expecting
> to audit the product's behaviour; read the SBOMs and the receipt instead.

## Download — v1.0.10

**→ [Releases · v1.0.10](https://github.com/uniQ-Ventures/armore-edge-public/releases/tag/v1.0.10)**

No account, no waitlist, no sign-in. 20 files: 7 installers, 10 Sigstore attestation
bundles, 3 signed update manifests.

| platform | file | size | signing |
|---|---|---|---|
| macOS Apple silicon | `Armore-Edge-1.0.10-arm64.dmg` | 129.1 MB | ✅ signed, notarised, **stapled** — opens without a Gatekeeper warning |
| macOS Intel | `Armore-Edge-1.0.10-x64.dmg` | 137.2 MB | ✅ signed and notarised — ⚠️ **no user-testing pass** |
| Windows x64 | `Armore-Edge-Setup-1.0.10-x64.exe` | 98.0 MB | ❌ **not Authenticode-signed — SmartScreen will warn you.** Click *More info → Run anyway* if you choose to proceed |
| Linux (Debian/Ubuntu) | `Armore-Edge-1.0.10-amd64.deb` | 92.5 MB | ❌ unsigned, x64 only — ⚠️ **no user-testing pass** |
| Linux (portable) | `Armore-Edge-1.0.10.AppImage` | 141.1 MB | ❌ unsigned — remember `chmod +x` before running it |

Also published: `*-mac.app.zip` for both Macs (used by the updater, not the normal way to install).

Every artifact carries a Sigstore attestation proving **where it was built**. That is not
the same thing as an OS-trusted code signature, and on Windows and Linux there is nothing
for your operating system to check.

### Before you install, three things we would rather you hear from us

1. **First run downloads a model — about 4.9 GB.** The app ships without one. It fetches
   Llama 3.1 8B Instruct (Q4_K_M) from a public model host and asks you first. It is a
   **third-party open-weights model that we package and run — Armore did not train it.**
   After that, the reasoning is local and works offline.
2. **Auto-update does not work end to end yet.** The manifests are published and we have
   not driven an update through, so do not rely on being offered one — including a
   security one. Update by hand for now.
3. **There is no CLI binary in this release.** Five targets build internally; none is
   published here. If a document tells you to run `armore …`, you cannot yet.

## Verifying what you downloaded

### The cheap check, with no extra tools — and no trust in us

Every installer's SHA-512 is named in a signed update manifest published beside it.
Download the manifest, compute the hash, compare:

```sh
TAG=v1.0.10
BASE="https://github.com/uniQ-Ventures/armore-edge-public/releases/download/$TAG"
curl -fLO "$BASE/latest-mac.yml"                                 # or latest.yml (Windows) / latest-linux.yml
curl -fLO "$BASE/Armore-Edge-1.0.10-arm64.dmg"

# the manifest carries base64-encoded sha512 — compute the same form and eyeball it
openssl dgst -sha512 -binary Armore-Edge-1.0.10-arm64.dmg | openssl base64 -A; echo
grep -A2 'arm64.dmg' latest-mac.yml
```

A match proves the bytes you hold are the bytes we published. This needs nothing installed
and requires no judgement about who we are.

⚠️ `latest-mac.yml`'s **top-level `path` names the Intel artifact** (`-x64-mac.app.zip`).
On an Apple-silicon Mac, read the `files:` list and match your own filename rather than the
top-level default.

### The full chain, with cosign

```sh
./scripts/verify-release.sh Armore-Edge-1.0.10-arm64.dmg
```

Needs [cosign](https://docs.sigstore.dev/cosign/system_config/installation/) ≥ 2.4. It
checks the signature, that the signer was our release workflow, and the Rekor
transparency-log entry.

**The signer identity names a private repository**, which returns 404 to you. That is
expected: cosign validates the embedded certificate and log entry and never contacts the
signing repo. You do not need access. It does mean this check asks you to accept that the
named repo is ours — which is why the sha512 route above exists.

## What is not here

- **No SBOMs or TUF metadata.** Our build produces 22 CycloneDX SBOMs and a TUF bundle;
  they are not published in this release, so you cannot inspect dependencies before
  installing. Only the Sigstore bundle beside each file.
- **No source.** See the notice at the top.
- **No hosted web app.** `app.edge.armore.ai` does not answer. The desktop app is the
  product today.

## Known issues in v1.0.10

| | |
|---|---|
| [#5753](https://github.com/uniQ-Ventures/armore-edge-public/issues) | A peer granted via `armore serve grant` is still refused by the running listener, and the refusal is logged nowhere |
| #5754 | Egress consent has no "always allow" — every egress asks again, forever |
| #5755 | On macOS a clean quit can file an "Armore Edge quit unexpectedly" crash report. Reported as happening on every exit; **in our own 2026-10-14 check on an arm64 Mac it did not reproduce, 0 of 3 clean quits.** If you see it, it is this, and it is not data loss |

More at [edge.armore.ai](https://edge.armore.ai) — including the measured limits and what
we are building next.
