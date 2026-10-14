# AeroSpace local patch: resolvedPid

Installed 2026-10-14 over AeroSpace 0.21.3-Beta (base commit in BASE_COMMIT).

Why: on macOS 27, NSRunningApplication.processIdentifier is -1 for some apps (Xcode 27's
Device Hub), so AeroSpace can't reach their windows over AX. The patch adds
`NSRunningApplication.resolvedPid`, which falls back to matching executableURL against
running processes, and uses it in MacApp.swift and AxSubscription.swift.

Reapply to a new version:
  git clone https://github.com/nikitabobko/AeroSpace.git && cd AeroSpace
  git checkout <tag> && git apply ~/.dotfiles/aerospace/patches/resolved-pid.patch
  swift build -c release --product AeroSpaceApp
  quit AeroSpace, then:
  cp .build/release/AeroSpaceApp /Applications/AeroSpace.app/Contents/MacOS/AeroSpace
  codesign --force --deep -s - /Applications/AeroSpace.app
  re-grant Accessibility (System Settings > Privacy & Security), relaunch

Revert: quit AeroSpace, delete /Applications/AeroSpace.app, unzip
~/.local/share/aerospace-patch/AeroSpace-0.21.3-Beta-original.zip into /Applications (or `brew reinstall --cask aerospace`).
