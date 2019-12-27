--- Availability
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.capacities

---@class Availability
---@field balancingData BalancingData
---@field modelName string
local Availability = {}
Availability.__index = Availability

---@public
---@param balancingData BalancingData
---@param modelName string @the path to the mdl of the model, starting with res/
---@return Availability the newly created capacities object
function Availability.create(modelName, balancingData)
  local cap = {}
  setmetatable(cap, Availability)
  cap.modelName = modelName
  cap.balancingData = balancingData
  return cap
end

---@public
---@param metadata table
function Availability:update(metadata)
  if self.balancingData[self.modelName] then
    local modelConfig = self.balancingData[self.modelName]
    if type(modelConfig.availability) == "table" then
      if type(metadata.availability) ~= "table" then
        metadata.availability = {}
      end
      if modelConfig.availability.yearFrom then
        metadata.availability.yearFrom = modelConfig.availability.yearFrom
      end
      if modelConfig.availability.yearTo then
        metadata.availability.yearTo = modelConfig.availability.yearTo
      end
    end
  end
end

return Availability