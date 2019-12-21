--- Modifiers
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.modifiers

---@class Modifiers
modifiers = {}

---@param settings table<string, table>
---@param carrier string @example AIR
---@param loadType string
---@return number
local function selectMultiplier(settings, carrier, loadType)
  loadType = loadType:lower()
  carrier = carrier:lower()
  local multipliers = settings._multipliers.capacity

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

---@param settings table<string, table>
---@param originalCapacity number
---@param modelName string
---@param carrier string @example AIR
---@param loadType string
---@return number
local function selectCapacity(originalCapacity, settings, modelName, carrier, loadType)
  loadType = loadType:lower()
  local multiplier = selectMultiplier(settings, carrier, loadType)

  if settings[modelName] then
    -- model specific override
    local modelConfig = settings[modelName]
    if type(modelConfig.capacities) == "table" then
      -- TODO support _all key as fallback for type
      if modelConfig.capacities[loadType] then
        return modelConfig.capacities[loadType] * multiplier
      end
    end
  end

  return originalCapacity * multiplier
end

local function selectLoadConfigCapacity(originalCapacity, settings, modelName, carrier, loadType, index)
  loadType = loadType:lower()
  local multiplier = selectMultiplier(settings, carrier, loadType)

  if settings[modelName] then
    -- model specific override
    local modelConfig = settings[modelName]
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

---@param fileName string
---@param data any
---@param settings table<string, table>
function modifiers.loadModel(fileName, data, settings)
  if type(data.metadata) == "table" and type(data.metadata.transportVehicle) == "table" then
    local modelName = string.gsub(fileName, ".*(res/models/model/.+[.]mdl)", "%1")

    local transportVehicle = data.metadata.transportVehicle

    -- handle compartments
    if type(transportVehicle.compartments) == "table" then
      for _, compartment in ipairs(transportVehicle.compartments) do
        if type(compartment) == "table" then
          for _, compartment2 in ipairs(compartment) do
            if type(compartment2) == "table" then
              for _, compartment3 in ipairs(compartment2) do
                if type(compartment3) == "table" and compartment3.capacity then
                  compartment3.capacity = selectCapacity(compartment3.capacity, settings, modelName, transportVehicle.carrier, compartment3.type)
                end
              end
            end
          end
        end
      end
    end

    -- handle compartmentsList
    if type(transportVehicle.compartmentsList) == "table" then
      for index, listEntry in ipairs(transportVehicle.compartmentsList) do
        if type(listEntry) == "table" and listEntry.loadConfigs then
          for _, loadConfig in ipairs(listEntry.loadConfigs) do
            if type(loadConfig) == "table" and loadConfig.cargoEntries then
              for _, cargoEntry in ipairs(loadConfig.cargoEntries) do
                if type(cargoEntry) == "table" and cargoEntry.capacity then
                  cargoEntry.capacity = selectLoadConfigCapacity(cargoEntry.capacity, settings, modelName, transportVehicle.carrier, cargoEntry.type, index)
                end
              end
            end
          end
        end
      end
    end

  end
  return data
end

return modifiers
