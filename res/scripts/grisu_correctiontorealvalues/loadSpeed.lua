--- LoadSpeed
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.capacities

---@class LoadSpeed
---@field balancingData BalancingData
---@field modelName string
local LoadSpeed = {}
LoadSpeed.__index = LoadSpeed

---@public
---@param balancingData BalancingData
---@param modelName string @the path to the mdl of the model, starting with res/
---@return LoadSpeed the newly created capacities object
function LoadSpeed.create(modelName, balancingData)
  local cap = {}
  setmetatable(cap, LoadSpeed)
  cap.modelName = modelName
  cap.balancingData = balancingData
  return cap
end

---@public
---@param transportVehicle table
function LoadSpeed:update(transportVehicle)
  if self.balancingData[self.modelName] then
    local modelConfig = self.balancingData[self.modelName]
    if modelConfig.loadSpeed then
      transportVehicle.loadSpeed = modelConfig.loadSpeed * self.balancingData._multipliers.loadSpeed
      -- early return when updated loadSpeed
      return
    end
  end
  if transportVehicle.loadSpeed then
    transportVehicle.loadSpeed = transportVehicle.loadSpeed * self.balancingData._multipliers.loadSpeed
  end
end

return LoadSpeed