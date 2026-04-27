-- MRPData~Init.lua
-- local _, MRPData = ...

local VERSION = 10400

if MRPData_API and (MRPData_API.VERSION or 0) >= VERSION then return end

MRPData.VERSION = VERSION
MRPData.Internal = {}
