# AeroSpace local patch: resolvedPid

Installed 2026-10-14 over AeroSpace 0.21.3-Beta (base commit in BASE_COMMIT).

Why: on macOS 27, NSRunningApplication.processIdentifier is -1 for some apps (Xcode 27's
Device Hub), so AeroSpace can't reach their windows over AX. The patch adds
`NSRunningApplication.resolvedPid`, which falls back to matching executableURL against
running processes, and uses it in MacApp.swift and AxSubscription.swift.

`brew upgrade` silently replaces the patched binary. Check after any upgrade: with a Device
Hub window open, `aerospace list-windows --all --format '%{app-bundle-id}' | grep dt.Devices`
prints nothing when the patch is missing.

Reapply to a new version (fresh temp dir, so a leftover clone can't block it):
  cd "$(mktemp -d)" && git clone https://github.com/nikitabobko/AeroSpace.git && cd AeroSpace
  git checkout <tag> && git apply ~/.dotfiles/aerospace/patches/resolved-pid.patch
  swift build -c release --product AeroSpaceApp
  mkdir -p ~/.local/share/aerospace-patch
  ditto -c -k --keepParent /Applications/AeroSpace.app ~/.local/share/aerospace-patch/AeroSpace-<tag>-original.zip
  quit AeroSpace, then:
  cp .build/release/AeroSpaceApp /Applications/AeroSpace.app/Contents/MacOS/AeroSpace
  codesign --force --deep -s - /Applications/AeroSpace.app
  re-grant Accessibility (System Settings > Privacy & Security: remove AeroSpace, re-add it), relaunch
  update BASE_COMMIT to the tag's commit

Revert: quit AeroSpace, delete /Applications/AeroSpace.app, unzip
~/.local/share/aerospace-patch/AeroSpace-<tag>-original.zip into /Applications (or `brew reinstall --cask aerospace`).
