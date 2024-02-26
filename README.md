# chatter

A mumble client written in flutter, targeting mobile primarily

## Getting Started

Chatter uses a few codegen packages ( app localizations, riverpod ), so when developing, its easiest to have
the dart `build_runner` (the thing that does the code generating) running in `watch` mode. In other words,
open a separate terminal and run `dart run build_runner watch`. This will have the `build_runner` watch for
file changes and recompute any codegen files as necessary.

## Roadmap

Make the connection to mumble servers transmit and recieve audio on:
- [ ] Android
- [ ] iOS
- Optionally:
  - [ ] Linux
  - [ ] Windows
  - [ ] MacOS
  - [ ] Web?
