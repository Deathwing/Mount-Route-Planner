# Changelog

## 1.4.0

### Fixes
- Fixed issues with timewalking steps
- Fixed issues with some alliance / horde specific steps showing for the wrong faction

## 1.3.0

### Changes
- Updated for build 12.0.5

## 1.2.0

### Fixes
- Wizard's Sanctum enter/exit edge is no longer incorrectly flagged as a hub transit skip, ensuring the step is visible in routes

### Added
- Added 7 missing holiday mounts: Love Witch's Sweeper, Spring Butterfly, Brewfest Bomber, Minion of Grumpus, The Headless Horseman's Ghoulish Charger, Illidari Doomhawk, and Azure Worldchiller
- Added Historian Ma'di (WoW Anniversary vendor) and Izzy Hollyfizzle (Feast of Winter Veil vendor) as new open-world step sources
- Added source name aliases for Doomwalker and Feast of Winter Veil to resolve mounts through alternative vendors

### Fixes
- Fixed 5 obtainable mounts being incorrectly filtered out by the legacy Flag 64 check in the export pipeline
- Corrected the generated Forbidden Reach UI map ID from `2107` to `2151` for the Storykeeper Ashekh vendor data and related step output

## 1.1.0

### Changes
- Introduced `MRPData_API` as a stable, versioned public API surface with UPPER_CASE keys (`DUNGEONS`, `RAIDS`, `WORLD_BOSSES`, `OPEN_WORLD`, `STEPS`)
- Moved version guard check from `_G.MRPData` to `MRPData_API`
- Added `MRPData~Types.lua` containing all type definitions previously located in MRP_Steps.lua and MRP_Data.lua

## 1.0.0

### Initial release
