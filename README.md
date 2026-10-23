# Armore Edge — public releases

Signed builds of **Armore Edge**, the desktop app that answers questions over your own
files with the reasoning running on your machine.

> ⚠️ **This is a release face, not the source tree.** It holds releases, a contributing
> guide, the release workflows and the verification script — **no application code.**
> Development happens in a separate private repository. Do not read this repo expecting
> to audit the product's behaviour; read the SBOMs and the receipt instead.

## Download — v1.0.11

**→ [Releases · v1.0.11](https://github.com/uniQ-Ventures/armore-edge-public/releases/tag/v1.0.11)**

No account, no waitlist, no sign-in. **104 files: 52 payloads and 52 Sigstore bundles,
paired one to one with none left over.**

| platform | file | size | signing |
|---|---|---|---|
| macOS Apple silicon | `Armore-Edge-1.0.11-arm64.dmg` | 139.0 MB | ✅ signed, notarised, **stapled** — opens without a Gatekeeper warning |
| macOS Intel | `Armore-Edge-1.0.11-x64.dmg` | 148.2 MB | ✅ signed and notarised — ⚠️ **no user-testing pass** |
| Windows x64 | `Armore-Edge-Setup-1.0.11-x64.exe` | 105.4 MB | ❌ **not Authenticode-signed — SmartScreen will warn you.** Click *More info → Run anyway* if you choose to proceed |
| Linux (Debian/Ubuntu) | `Armore-Edge-1.0.11-amd64.deb` | 95.3 MB | ❌ unsigned, **x86_64 only** — ⚠️ **tested under WSL2, not on a bare-metal desktop** |
| Linux (portable) | `Armore-Edge-1.0.11.AppImage` | 153.1 MB | ❌ unsigned — remember `chmod +x` before running it |

Also published: `*-mac.app.zip` for both Macs (used by the updater, not the normal way to
install), 5 blockmaps, and 3 signed update manifests.

Every artifact carries a Sigstore attestation proving **where it was built**. That is not
the same thing as an OS-trusted code signature, and on Windows and Linux there is nothing
for your operating system to check.

**There is no arm64 Linux app.** The `package-app` matrix is four legs — two macOS, one
Linux x86_64, one Windows — so there is no arm64 `.deb` and no arm64 AppImage. The arm64
Linux **CLI** does ship, below.

## New in v1.0.11

- **`armore mcp-serve` — point your AI tools at this machine.** Bridges an external MCP
  client (Claude Code, Codex, Copilot, Cursor) to the model on your own hardware. This is
  the **inbound** direction: an outside tool asks Armore. Armore reaching out to other
  services as a client is not in this release.
- **Your machines can share the work.** A machine with no model of its own can ask a paired
  machine that has one, over your own encrypted link. We have run this **between two
  machines**; with more than two we are not yet confident the right one answers every time.
- **It refuses rather than guessing.** Ask about something that is not in your documents
  and you get an honest *"Not found"* instead of a confident answer assembled from nothing.
- **The command-line tool now ships inside the installer** on all three systems, so it
  carries the same signature the app does. On Linux the package also links it to
  `/usr/bin/armore`.
- **QR pairing is gone, not postponed.** Pairing is the workspace-key path and the short
  code that makes it safe.

## The command-line tool

**It is in the installer** — if you installed the app, you have it. On Linux the package
puts it on your `PATH`; on macOS and Windows it lives inside the application and the app
shows you the full path.

It is **also published here on its own**, if you would rather not install the app:

| | |
|---|---|
| CLI | `armore-darwin-arm64`, `armore-darwin-x86_64`, `armore-linux-arm64`, `armore-linux-x86_64`, `armore.exe` |
| git remote helper | the matching `git-remote-armore-*` for each, so `git` can push a repository to a workspace over the mesh |
| SDK addons | 4 native `.node` addons, for embedding the engine in your own Node application |

⚠️ The loose download is a **bare binary** — it does not carry the installer's notarisation,
so macOS may quarantine it on first run. The copy inside the installer does not have that
problem.

⚠️ The `aarch64-linux` build is made **without on-device inference**, so it is not the same
binary as its siblings.

## Before you install, two things we would rather you hear from us

1. **First run downloads a model — about 4.9 GB.** The app ships without one. It fetches
   Llama 3.1 8B Instruct (Q4_K_M) from a public model host and asks you first. It is a
   **third-party open-weights model that we package and run — Armore did not train it.**
   After that, the reasoning is local and works offline.
2. **Auto-update does not work end to end yet.** The manifests are published and we have
   not driven an update through, so do not rely on being offered one — including a
   security one. Update by hand for now.

## Verifying what you downloaded

### The cheap check, with no extra tools — and no trust in us

Every installer's SHA-512 is named in a signed update manifest published beside it.
Download the manifest, compute the hash, compare:

```sh
TAG=v1.0.11
BASE="https://github.com/uniQ-Ventures/armore-edge-public/releases/download/$TAG"
curl -fLO "$BASE/latest-mac.yml"                                 # or latest.yml (Windows) / latest-linux.yml
curl -fLO "$BASE/Armore-Edge-1.0.11-arm64.dmg"

# the manifest carries base64-encoded sha512 — compute the same form and eyeball it
openssl dgst -sha512 -binary Armore-Edge-1.0.11-arm64.dmg | openssl base64 -A; echo
grep -A2 'arm64.dmg' latest-mac.yml
```

A match proves the bytes you hold are the bytes we published. This needs nothing installed
and requires no judgement about who we are.

⚠️ `latest-mac.yml`'s **top-level `path` names the Intel artifact** (`-x64-mac.app.zip`).
On an Apple-silicon Mac, read the `files:` list and match your own filename rather than the
top-level default.

### The full chain, with cosign

```sh
./scripts/verify-release.sh Armore-Edge-1.0.11-arm64.dmg
```

Needs [cosign](https://docs.sigstore.dev/cosign/system_config/installation/) ≥ 2.4. It
checks the signature, that the signer was our release workflow, and the Rekor
transparency-log entry.

**The signer identity names a private repository**, which returns 404 to you. That is
expected: cosign validates the embedded certificate and log entry and never contacts the
signing repo. You do not need access. It does mean this check asks you to accept that the
named repo is ours — which is why the sha512 route above exists.

⚠️ **Every digest changed in this release**, because packaging re-cut by tag. If you kept a
hash from v1.0.10, it will not match — that is expected, and it is why the commands above
read the manifest rather than quoting a digest.

## What is not here

- **No source.** See the notice at the top.
- **No hosted web app.** `app.edge.armore.ai` does not answer. The desktop app is the
  product today.

⚪ **SBOMs and TUF metadata ARE published now** — 22 CycloneDX SBOMs (one per Rust crate,
one for the JS tree) and a TUF metadata bundle ship with this release, so you can inspect
dependencies before installing.

## Known issues in v1.0.11

| | |
|---|---|
| [#5753](https://github.com/uniQ-Ventures/armore-edge-public/issues) | A peer granted via `armore serve grant` is still refused by the running listener, and the refusal is logged nowhere |
| #5754 | Egress consent has no "always allow" — every egress asks again, forever |
| #5755 | On macOS a clean quit can file an "Armore Edge quit unexpectedly" crash report. Reported as happening on every exit; **in our own 2026-10-14 check on an arm64 Mac it did not reproduce, 0 of 3 clean quits.** If you see it, it is this, and it is not data loss |
| #6448 | With more than two machines able to answer, a later request can be routed to the wrong one. Two machines is the supported shape today |

More at [edge.armore.ai](https://edge.armore.ai) — including the measured limits and what
we are building next.
