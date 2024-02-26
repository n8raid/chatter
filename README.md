# chatter

A mumble client written in flutter, targeting mobile primarily

## Getting Started

Install Flutter on your local machine

Chatter uses a few codegen packages ( app localizations, riverpod ), so when developing, its easiest to have
the dart `build_runner` (the thing that does the code generating) running in `watch` mode. In other words,
open a separate terminal and run

```sh
dart run build_runner watch
```

For one-shot codegen'ing, you can just run

```sh
dart run build_runner build
```

This will have the `build_runner` watch for file changes and recompute any codegen files as necessary.

## Roadmap

### Make the connection to mumble servers transmit and recieve audio on:
- [ ] Android
- [ ] iOS
- Optionally:
  - [ ] Linux
  - [ ] Windows
  - [ ] MacOS
  - [ ] Web?

### CI/CD

- [ ] Setup Github actions to auto lint and test PRs to `main`
- [ ] Setup some simple git hooks to do the same on dev's machine before committing

### Other

- [ ] Add nix flake for dev env
