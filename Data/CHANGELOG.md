# Changelog

## 1.1.0

### Changes
- Introduced `MRPData_API` as a stable, versioned public API surface with UPPER_CASE keys (`DUNGEONS`, `RAIDS`, `WORLD_BOSSES`, `OPEN_WORLD`, `STEPS`)
- Moved version guard check from `_G.MRPData` to `MRPData_API`
- Added `MRPData~Types.lua` containing all type definitions previously located in MRP_Steps.lua and MRP_Data.lua

## 1.0.0

### Initial release
