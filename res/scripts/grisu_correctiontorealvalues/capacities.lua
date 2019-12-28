--- Capacities
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.capacities

---@class Capacities
---@field balancingData BalancingData
---@field modelName string
local Capacities = {}
Capacities.__index = Capacities

---@public
---@param balancingData BalancingData
---@param modelName string @the path to the mdl of the model, starting with res/
---@return Capacities the newly created capacities object
function Capacities.create(modelName, balancingData)
  local cap = {}
  setmetatable(cap, Capacities)
  cap.modelName = modelName
  cap.balancingData = balancingData
  return cap
end

---@public
---@param transportVehicle table
function Capacities:update(transportVehicle)
  self:updateCompartments(transportVehicle)
  self:updateCompartmentLists(transportVehicle)
end

---@private
---@param transportVehicle table
function Capacities:updateCompartments(transportVehicle)
  if type(transportVehicle.compartments) == "table" then
    for _, compartment in ipairs(transportVehicle.compartments) do
      if type(compartment) == "table" then
        for _, compartment2 in ipairs(compartment) do
          if type(compartment2) == "table" then
            for _, compartment3 in ipairs(compartment2) do
              if type(compartment3) == "table" and compartment3.capacity then
                compartment3.capacity = self:selectCapacity(compartment3.capacity,
                    transportVehicle.carrier, compartment3.type)
              end
            end
          end
        end
      end
    end
  end
end

---@private
---@param transportVehicle table
function Capacities:updateCompartmentLists(transportVehicle)
  if type(transportVehicle.compartmentsList) == "table" then
    for index, listEntry in ipairs(transportVehicle.compartmentsList) do
      if type(listEntry) == "table" and listEntry.loadConfigs then
        for _, loadConfig in ipairs(listEntry.loadConfigs) do
          if type(loadConfig) == "table" and loadConfig.cargoEntries then
            for _, cargoEntry in ipairs(loadConfig.cargoEntries) do
              if type(cargoEntry) == "table" and cargoEntry.capacity then
                cargoEntry.capacity = self:selectLoadConfigCapacity(cargoEntry.capacity,
                    transportVehicle.carrier, cargoEntry.type, index)
              end
            end
          end
        end
      end
    end
  end
end

---@private
---@param carrier string @example AIR
---@param loadType string
---@return number
function Capacities:selectMultiplier(carrier, loadType)
  loadType = loadType:lower()
  carrier = carrier:lower()
  local multipliers = self.balancingData._multipliers.capacity

  if multipliers[carrier] then
    local carrierSpecific = multipliers[carrier]
    -- carrier and type specific fallback
    if carrierSpecific[loadType] then
      return carrierSpecific[loadType]
    end
    -- fallback to carrier _all
    if carrierSpecific._all then
      return carrierSpecific._all
    end
    -- fallthrough to _all fallback
  end

  -- type specific fallback
  if multipliers._all[loadType] then
    return multipliers._all[loadType]
  end

  -- last fallback
  return multipliers._all._all
end

---@private
---@param originalCapacity number
---@param carrier string @example AIR
---@param loadType string @the type of the load, example passengers or coal
---@return number
function Capacities:selectCapacity(originalCapacity, carrier, loadType)
  loadType = loadType:lower()
  local multiplier = self:selectMultiplier(carrier, loadType)

  if self.balancingData[self.modelName] then
    -- model specific override
    local modelConfig = self.balancingData[self.modelName]
    if type(modelConfig.capacities) == "table" then
      -- TODO support _all key as fallback for type
      if modelConfig.capacities[loadType] then
        return modelConfig.capacities[loadType] * multiplier
      end
    end
  end

  return originalCapacity * multiplier
end

---@private
---@param originalCapacity number
---@param carrier string @example AIR
---@param loadType string @the type of the load, example passengers or coal
---@return number
function Capacities:selectLoadConfigCapacity(originalCapacity, carrier, loadType, index)
  loadType = loadType:lower()
  local multiplier = self:selectMultiplier(carrier, loadType)

  if self.balancingData[self.modelName] then
    -- model specific override
    local modelConfig = self.balancingData[self.modelName]
    if type(modelConfig.loadConfigs) == "table" then
      if modelConfig.loadConfigs[loadType] then
        if type(modelConfig.loadConfigs[loadType]) == "table" and modelConfig.loadConfigs[loadType][index] then
          return modelConfig.loadConfigs[loadType][index] * multiplier
        end
        if modelConfig.loadConfigs[loadType] then
          return modelConfig.loadConfigs[loadType] * multiplier
        end
      end
      if modelConfig.loadConfigs._all then
        if type(modelConfig.loadConfigs._all) == "table" and modelConfig.loadConfigs._all[index] then
          return modelConfig.loadConfigs._all[index] * multiplier
        end
        if modelConfig.loadConfigs._all then
          return modelConfig.loadConfigs._all * multiplier
        end
      end
    end
  end

  return originalCapacity * multiplier
end

return Capacities
