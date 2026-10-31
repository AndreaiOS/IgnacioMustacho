# Ignacio Mustacho — App Store visual package

Prepared locally on 31 October 2026. Nothing has been uploaded or published. All English copy describes implemented gameplay; online leaderboard availability is deliberately omitted until tested against the actual Apple configuration.

## Deliverables

- `Icons/AppIcon-1024.png`: full-bleed, opaque RGB app icon, integrated in `Sources/Assets.xcassets/AppIcon.appiconset`.
- `Icons/CharacterIcon-Master.png`: unmodified generated master, based on the canonical character and current game uniform.
- `Icons/AppIcon-{180,120,60,40}.png`: deterministic export sizes for visual review; no baked-in rounded corners.
- `Screenshots/01-Shadow-Basketball.png`, `02-Hit-The-Zone.png`, `03-Find-Your-Flow.png`, `04-Keep-The-Ego.png`: 1320×2868 RGB promotional screenshots for the 6.9-inch iPhone slot. Native typography frames actual app captures; screenshots are scaled, not repainted or AI-reconstructed.
- `RawScreenshots`: original XCUITest attachments from iPhone 18 Pro Max. Their manifest retains test provenance. Actual interface, real app state, no fabricated scores or online ranking.
- `Branding`: launch-screen and Home captures. The iOS launch storyboard shows the same arena without text or delay. The character badge and title live in the immediately interactive Home; there is no forced splash timer or fake loading bar.
- `Metadata-en.json`: English name, subtitle, promotional text, description, keywords, review-note draft and explicit owner-supplied fields. Lengths checked locally.
- `Art-Prompts.json`: exact icon prompt and built-in imagegen provenance. No external generation service purchased.

## Source and export

Canonical identity: `Documentation/CharacterReferences/Ignacio-Canonical.png`. Character art and arena references stay unchanged. The icon is a new portrait interpretation using the same skin tone, full fringe, swept side hair and oversized moustache. No ball, team logo or affiliation claim.

`Scripts/export_store_art.swift` converts the generated master to required RGB platform renditions and preview sizes. `Scripts/make_store_screenshots.swift` lays out the unaltered app captures with vector text and borders. The earlier temporary IM-only technical icon was replaced; it is not the delivered icon.

## Apple requirements consulted

- [App icon asset catalogs](https://developer.apple.com/documentation/xcode/configuring-your-app-icon): 1024×1024 source icon and Xcode-generated variants.
- [Launching](https://developer.apple.com/design/human-interface-guidelines/launching): immediate launch, first-screen continuity, branding in the app rather than a forced launch advertisement.
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/): 1–10 images, PNG/JPEG without alpha; 1320×2868 accepted for the 6.9-inch slot.
- [Platform metadata](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/): promotional text ≤170 characters, description ≤4000, keywords ≤100 bytes; support URL required.
- [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/): name/subtitle ≤30 characters, privacy policy URL and bundle identity.

## Current build and rewards

Bundle ID: `com.ignaciomustacho.shadowbasketball`. Historical signed development archive: `BuildArtifacts/Ignacio-1.0-1-Current.xcarchive`; packaging and signature verified for that earlier rewards snapshot. It predates the 320 BPM curve, final-voice removal and club polish. Earlier archives use the old prototype ID. No distribution export or upload performed.

`GameCenter/Achievements-en.json` contains six proposed local achievement IDs, pre-earned/earned copy and explicit in-game thresholds. `GameCenter/award-*.png` are six original vector badges exported by `Scripts/make_achievement_badges.swift`, 1024×1024 RGB at 72 ppi. Their 10-point Game Center reward values are separate from the 10/23/33/50/81/100 game thresholds. Apple requires a localized image of this size and color space: [achievement reference](https://developer.apple.com/help/app-store-connect/reference/game-center/achievements/). These files do not create Apple records.

Screenshots were refreshed after club polish from the passing iPhone 18 Pro Max suite (22 app tests, 12 UI tests; plus 32 domain tests). The GameOver and Gameplay captures were replaced after the final quote-wrapping regression test passed on both simulator sizes. Four promotional cards were regenerated from these current captures. Synthetic DEBUG milestone/320 BPM scenes are kept only in Documentation/Polish, outside this promotional package. Raw `RewardAnimations.png` is a DEBUG animation review grid, excluded from promotional screenshots. `GameOver.png` is a real zero-point defeat. Artwork prompts for the six reactions are in `Documentation/Celebration-Prompts.json` and `Documentation/Celebration-Extra-Prompts.json`.

## Still required from the owner / Apple

Confirm final display name; provide working support/privacy URLs, copyright holder and review contact; confirm commercial rights to supplied character references/assets. Review privacy and age-rating answers against the final app, including optional Game Center. No invented URLs, account records or rights declarations are included. Pricing, territories, distribution signature validation and eventual upload remain separate decisions.

See `Documentation/Device-Release.md` for the verified local team/device/build state and the distinction between GameKit code, Apple service configuration and TestFlight distribution.
