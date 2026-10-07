# Armore Edge — releases

The public release face for **Armore Edge**: a private AI assistant that runs fully on your own
device. A local model does the reasoning — nothing you type, and no file or repository you add,
is sent to a cloud or third party for inference.

This repository carries **release artifacts and release pipelines only**. Development happens in a
separate private repository, so there is no application source here.

## Downloads

**There is no release on this repository yet.** Signed builds for v1.0.8 are cut and attested, and
they publish to the [Releases](../../releases) page on release day — until then that page is empty
and nothing here is downloadable.

When they land, the set is:

| Platform | Artifact |
|---|---|
| macOS (Apple Silicon / Intel) | `.dmg` — signed and notarised |
| Windows | `.exe` installer — **not** Authenticode-signed yet |
| Linux | `.deb`, `.AppImage` — unsigned |
| CLI | `armore-*` for macOS, Linux, Windows |

Every artifact carries a Sigstore attestation of how and where it was built. That proves
provenance; it is not the same thing as an OS-trusted code signature, and only the macOS build
has one of those.

## What leaves your device

- **Inference: nothing.** The model runs locally.
- **Web search is optional and off by default.** If you turn it on, the *query* leaves your device
  and reaches an upstream search engine that we do not run.
- **Sync between your own devices traverses a relay.** It carries content the relay cannot read,
  but it can see that two devices are talking, when, for how long, how much, and their network
  addresses. We do not claim "no server is ever involved" — that would be untrue for sync.

The model weights are a **third-party, open-weights model** that Armore packages and runs. Armore
did not train the model; Armore wrote the application around it.

## Status

Mobile (iOS/Android) pipelines are wired but the apps are early scaffold — a tagged release does
not yet produce a store-ready mobile build. **macOS, Windows and Linux are the real release
targets today.**

Browser access is not open: the hosted route answers `401` to everyone, and in v1.0.8 the browser
client cannot ask the model anything even when served from your own machine. The desktop app is
the whole product today.

## Contributing

Please open an issue or a pull request rather than pushing to `main` directly. See
`CONTRIBUTING.md` for the backlog convention that tickets are expected to follow.
