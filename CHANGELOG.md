# Mount Route Planner

## [v1.2.0](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.2.0) (2026-01-23)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.2.0) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Added Reset Instances button for repeatable instances

### Changes
- Updated to support the Midnight pre-patch
- Various fixes and improvements
- Overall data updates

## [v1.1.6](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.6) (2025-08-26)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.6) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Added chinese (China/Taiwan) translation (thanks to fang2hou)

### Changes
- Updated russian translation (thanks to ZamestoTV)

## [v1.1.5](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.5) (2025-08-12)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.5) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Added more items

## [v1.1.4](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.4) (2025-08-05)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.4) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Bug Fixes
- Fixed an issue when TomTom is enabled, rendering the pathfinding unusable

## [v1.1.3](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.3) (2025-08-04)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.3) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Added support for patch 11.2.0
- Added option to ignore specific helpful items
- Action options are now using ingame tooltips for spells and items

### Bug Fixes
- Fixed an edge case when pathfinding was not available
- Fixed an issue when the mount icon was not available
- Fixed an issue with 'Ultrasafe Transporter: Gadgetzan'
- Clicking info icons will no longer close the main frame

### Changes
- Mount notes are now having a clear indicator and display at the bottom of the tooltip

## [v1.1.2](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.2) (2025-08-02)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.2) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- AutoSkip and AutoAdvance are now saved per character
- Added option to filter out all LFR content
- Added Kirin Tor teleport items (#7, thanks to @Kebabpizza)

### Bug Fixes
- Fixed an issue while being inside pvp content (#8)
- Fixed issues with cooldowns of items
- Fixed an issue with the hearthstone
- Fixed location marker for Rukhmar
- Fixed entrance detection for Ny'alotha

## [v1.1.1](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.1) (2025-07-27)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.1) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Added more hearthstone locations for main cities

### Bug Fixes
- Fixed an issue with the minimap button and main frame to reset with each UI reload
- Fixed an issue with minimap button not being shown in some cases
- Fixed an issue with item names and buttons

## [v1.1.0](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.1.0) (2025-07-27)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.1.0) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Added support for Mists of Pandaria Classic
- Added support for over a dozen of teleportation items
- Added support for showing missing teleport items from the inventory

![Helpful Items Warning](Screenshots/Gallery_6.png)

### Bug Fixes
- Fixed an issue with Blizzard waypoints not being drawn on some maps (i.e. Dalaran)
- Fixed an issue with buttons while being in combat
- Fixed an issue with the usability of items (i.e. Hearthstone charges)
- Fixed an issue with world boss steps advancing without the need of completion
- Fixed an issue with pathfinding in Shadowlands
- Fixed an issue with pathfinding using Tol Barad for Eastern Kingdom routes
- Fixed an issue with many waypoints not having correct conditions

## [v1.0.1](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.0.1) (2025-07-23)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.0.1) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Bug Fixes
- Fixed an issue with unresolvable Binding Locations for the Hearthstone
- Fixed an issue with referencing developer tools

## [v1.0.0](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v1.0.0) (2025-07-23)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v1.0.0) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Added
- Full removal of dependency on Simple Armory.
  - The addon now independently checks for missing mounts from the user's account.
  - Introduced dynamic filtering and step tracking.
- New dynamic navigation system:
  - Utilizes a Dijkstra algorithm to determine the most efficient route to the next objective.
  - Supports travel abilities including hearthstones and mage teleports/portals.
  - Initial implementation; edge cases are still being refined.
- Full localization support (still localization missing so)

### Changed
- Step display now includes all difficulties a mount can drop on.
- Added warnings for incorrect difficulty settings during step progression.

### Improved
- Major "backend" refactor to improve scalability and stability.

## [v0.3.2](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v0.3.2) (2025-07-16)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v0.3.2) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Bug Fixes
- Added missing Zandalar Teleporter for Horde characters

## [v0.3.1](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v0.3.1) (2025-07-16)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v0.3.1) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Bug Fixes
- Fixed issues related to importing the new content format

## [v0.3.0](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v0.3.0) (2025-07-07)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v0.3.0) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Changes
- Waypoints are now saved only within the session, applies to both TomTom and Blizzard's waypoint system.
- TomTom will no longer print out debug messages about waypoints.
- TomTom is now enabled by default. You can disable it in the settings.

### Bug Fixes
- Player's TomTom waypoints will no longer be removed by Mount Route Planner in some cases.

## [v0.2.0](https://github.com/Deathwing/Mount-Route-Planner/releases/tag/v0.2.0) (2025-07-07)
[Full Changelog](https://github.com/Deathwing/Mount-Route-Planner/commits/v0.2.0) [Previous Releases](https://github.com/Deathwing/Mount-Route-Planner/releases)

### Changes
- Added russian translation (thanks to ZamestoTV)
- Added german translation
- Overall clean up of the project (removed a lot of global vars…)

### Bug Fixes
- Fixed an issue preventing data from Firefox to be imported correctly
- Fixed an issue where Boss names didn't match correctly (i.e. ‘Spine of Deathwing’ for ‘Deathwing’)
- Fixed multiple issues related to clients not running the English locale (no icons shown, item actions were not working, mounts not found, etc.)
