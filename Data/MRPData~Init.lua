-- MRPData~Init.lua
-- local _, MRPData = ...

local VERSION = 10000

if _G.MRPData and (_G.MRPData.VERSION or 0) >= VERSION then return end

MRPData.VERSION = VERSION
MRPData.Internal = {}
