{
  description = "An example project using flutter";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.android-nixpkgs.url = "github:tadfisher/android-nixpkgs";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShell = let
        android-nixpkgs = pkgs.callPackage inputs.android-nixpkgs {};
        android-sdk = android-nixpkgs.sdk (sdkPkgs:
          with sdkPkgs; [
            cmdline-tools-latest
            build-tools-30-0-3
            # This version needs to match the GRADLE_OPTS env var down below, vice versa
            build-tools-34-0-0
            platform-tools
            platforms-android-28
            platforms-android-29
            platforms-android-31
            platforms-android-33
            platforms-android-34
            emulator
          ]);
        # See below link for configuring ruby env with bundix
        # https://github.com/the-nix-way/nix-flake-dev-environments/tree/main/ruby-on-rails
        rubyEnv = pkgs.bundlerEnv {
          name = "ruby-env";
          inherit (pkgs) ruby;
          gemdir = ./android;
        };
        # buildNodeJs = pkgs.callPackage "${nixpkgs}/pkgs/development/web/nodejs/nodejs.nix" {
        #   python = pkgs.python3;
        # };
        # nodejs = buildNodeJs {
        #   enableNpm = true;
        #   version = "20.0.0";
        #   sha256 = "sha256-Q5xxqi84woYWV7+lOOmRkaVxJYBmy/1FSFhgScgTQZA=";
        # };
      in 
        pkgs.mkShell {
          # Fix an issue with Flutter using an older version of aapt2, which does not know
          # an used parameter.
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${android-sdk}/share/android-sdk/build-tools/34.0.0/aapt2";
          FLUTTER_ROOT = "${pkgs.flutter}";
          # nativeBuildInputs = with pkgs; [
          # ];
          buildInputs = with pkgs; [
            flutter
            # pkg-config
            jdk17
            android-sdk
            rubyEnv
            rubyEnv.wrappedRuby
            # fastlane
            bundix
            # gems
            firebase-tools
            # nodejs
          ];
          shellHook = ''
            export PATH="$PATH":"$HOME/.pub-cache/bin" 
          '';
        };
    });
}
