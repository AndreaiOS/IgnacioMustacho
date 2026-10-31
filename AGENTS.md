# Repository Guidelines

## Project Structure & Module Organization

This project directory is currently empty: no source code, tests, assets, or build configuration have been added. Keep project code, tests, assets, and configuration here, and document the actual layout in `README.md` when scaffolding is introduced.

For an iOS implementation, follow the parent workspace’s Clean Architecture guidance: separate Domain (entities, use cases, protocols), Data (persistence and networking implementations), and Presentation (views and presentation state). Dependencies point inward; Domain must remain independent of UI and storage frameworks. Connect implementations through dependency injection at a composition root.

## Build, Test, and Development Commands

No build, test, lint, or development commands are configured yet. Add exact commands to `README.md` alongside prerequisites, tool versions, and setup steps when selecting the toolchain.

For Xcode projects, first inspect available schemes with `xcodebuild -list`. Document a verified test command using the actual scheme and simulator destination; do not assume either exists. Run commands from this directory unless setup documentation specifies otherwise.

## Coding Style & Naming Conventions

For iOS development, prefer Swift, four-space indentation, `UpperCamelCase` type names, and `lowerCamelCase` members. Keep business logic outside views, handle errors explicitly, and avoid force unwraps and hidden global dependencies. Configure SwiftLint and a Swift formatter when adding Swift tooling; neither is installed or configured by this guide.

## Testing Guidelines

Follow red–green–refactor and add regression tests before bug fixes. Use Swift Testing or XCTest as configured, plus XCUITest for critical user journeys. Name tests for behavior and expected outcomes. Inject clocks, networking, and storage to keep tests deterministic. No coverage threshold is established. Run relevant tests, builds, and lint checks; report checks that cannot run.

## Commit & Pull Request Guidelines

No Git repository or commit history exists here yet. Use concise, imperative commit subjects and focused changes. PRs should describe behavior and architectural impact, link relevant issues, summarize validation, and include screenshots for UI changes.

## Security & Configuration

Never commit secrets. Use Keychain for sensitive on-device data. Include accessibility, localization readiness, privacy, and responsive layouts in acceptance criteria.
