-- MRP_Types.lua
-- local _, MRP = ...

---@class MRPAPI
---@field DATA MRPDataAPI the main data API, containing all route and step information
---@field FARSTRIDER FarstriderLibAPI the API for accessing FarstriderLib's pathfinding features
---@field Rebuild fun() Clears all cached pathfinding data and forces a full rebuild on the next pathfinding request. Call this after updating any data.
