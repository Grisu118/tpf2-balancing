--- Maintenance
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.capacities

---@class Maintenance
---@field balancingData BalancingData
---@field modelName string
Maintenance = {}
Maintenance.__index = Maintenance

---@public
---@param balancingData BalancingData
---@param modelName string @the path to the mdl of the model, starting with res/
---@return Maintenance the newly created capacities object
function Maintenance.create(modelName, balancingData)
  local cls = {}
  setmetatable(cls, Maintenance)
  cls.modelName = modelName
  cls.balancingData = balancingData
  return cls
end

---@public
---@param metadata table
function Maintenance:update(metadata)
  if self.balancingData[self.modelName] then
    local modelConfig = self.balancingData[self.modelName]
    if type(modelConfig.maintenance) == "table" then
      if type(metadata.maintenance) ~= "table" then
        metadata.maintenance = {}
      end
      if modelConfig.maintenance.lifespan then
        -- change from years to ingame value
        local newLifeSpan = modelConfig.maintenance.lifespan * 730.5
        metadata.maintenance.lifespan = newLifeSpan * self.balancingData._multipliers.lifespan
        -- early return when updated lifespan
        return
      end
    end
  end
  if type(metadata.maintenance) == "table" and metadata.maintenance.lifespan then
    metadata.maintenance.lifespan = metadata.maintenance.lifespan * self.balancingData._multipliers.lifespan
  end
end

return Maintenance