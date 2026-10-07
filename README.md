# Armore Edge — releases

The public release face for **Armore Edge**: a private AI assistant that runs fully on your own
device. A local model does the reasoning — nothing you type, and no file or repository you add,
is sent to a cloud or third party for inference.

This repository carries **release artifacts and release pipelines only**. Development happens in a
separate private repository.

## Downloads

Signed builds are published on the [Releases](../../releases) page.

| Platform | Artifact |
|---|---|
| macOS (Apple Silicon / Intel) | `.dmg` |
| Windows | `.exe` installer |
| Linux | `.deb`, `.AppImage` |
| CLI | `armore-*` for macOS, Linux, Windows |

## What leaves your device

- **Inference: nothing.** The model runs locally.
- **Web search is optional and off by default.** If you turn it on, the *query* leaves your device
  and reaches an upstream search engine.
- **Sync between your own devices traverses a relay.** It carries content the relay cannot read,
  but it can see that two devices are talking, when, for how long, how much, and their network
  addresses. We do not claim "no server is ever involved" — that would be untrue for sync.

The model weights are a **third-party, open-weights model** that Armore packages and runs. Armore
did not train the model; Armore wrote the application around it.

## Status

Mobile (iOS/Android) pipelines are wired but the apps are early scaffold — a tagged release does
not yet produce a store-ready mobile build. **macOS, Windows and Linux are the real release
targets today.**

## Contributing

Write access is by pull request; direct pushes to `main` are blocked. See `CONTRIBUTING.md`.
