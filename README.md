# Fishy Motion

**Spot the odd movement.**

Six identical swimmers follow a visible rule. One of them lies — turns early, holds speed, pauses, or leads the cycle. You tap the odd one. After you answer, the game shows what was different.

[![Platform](https://img.shields.io/badge/platform-iPhone%20%C2%B7%20iPad%20%C2%B7%20iOS%2018%2B-000000)](#app-target)
[![Language](https://img.shields.io/badge/Swift-6-F05138)](#build-and-run)
[![UI](https://img.shields.io/badge/UI-SwiftUI-0A84FF)](#build-and-run)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Play

A round is one observation, not a speed exam:

1. Watch the school.
2. They all look the same on purpose.
3. Tap the one whose motion breaks the rule.
4. Read the short replay of the difference.

Stars reward a clean first look, not a stopwatch. A hint is allowed; it costs a star.

## Why the look never gives it away

The liar is never a different color, size, or species. If one fish is orange among blue, the puzzle is already over. The only signal is behavior in time.

## Worlds

1. **Coral Reef** — open, honest tells
2. **Sunken Ruins** — columns force a loop
3. **Deep Trench** — smaller tells, more bodies
4. **Crystal Cave** — reflections, quieter lies
5. **Alien Ocean** — same rules, stranger water

Each world has twelve short observations. Themes (classic fish, robots, ghosts, toys, jellyfish, koi) change how the school looks, never which body is odd.

## App target

- iPhone and iPad (universal)
- iOS 18+
- Portrait on iPhone; portrait and landscape on iPad
- No account, no tracking, no network

Bundle ID: `com.sergiiziborov.fishymotion`

## Build and run

```bash
brew install xcodegen   # if needed
cd fishy-motion
xcodegen generate
open FishyMotion.xcodeproj
```

Select an iPhone or iPad simulator, then Run.

Unit tests cover motion fairness, seeded liars, and star policy:

```bash
xcodebuild test \
  -scheme FishyMotion \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>'
```

## Project layout

```
FishyMotion/
  App/              # scene, navigation, play session
  Game/Engine/      # motion, lies, catalog, detectability
  Game/Creatures/   # identical swimmers, six themes
  Game/Stage/       # school, bubbles, explanation strip
  Features/         # home, play, result, worlds, daily, collection
  Persistence/      # local stars and seen moves
  DesignSystem/     # ocean palette and buttons
```

The simulation (`School`, `Motion`) is independent of SwiftUI so a tell can be tested without a scene.

## License

MIT. See [LICENSE](LICENSE). Privacy notes live in [PRIVACY.md](PRIVACY.md).
