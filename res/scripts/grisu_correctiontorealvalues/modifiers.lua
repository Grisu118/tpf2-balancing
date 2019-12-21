--- Modifiers
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.modifiers

---@class Modifiers
modifiers = {}

---@param settings table<string, table>
---@param originalCapacity number
---@param carrier string @example AIR
---@param loadType string
---@return number
local function selectFallbackMultiplier(originalCapacity, settings, carrier, loadType)
  local lowerType = loadType:lower()
  local lowerCarrier = carrier:lower()
  local fallbacks = settings._fallbacks.multipliers

  if fallbacks[lowerCarrier] then
    local carrierSpecific = fallbacks[lowerCarrier]
    -- carrier and type specific fallback
    if carrierSpecific[lowerType] then
      return originalCapacity * carrierSpecific[lowerType]
    end
    -- fallback to carrier _all
    if carrierSpecific._all then
      return originalCapacity * carrierSpecific._all
    end
    -- fallthrough to _all fallback
  end

  -- type specific fallback
  if fallbacks._all[lowerType] then
    return originalCapacity * fallbacks._all[lowerType]
  end

  -- last fallback
  return originalCapacity * fallbacks._all._all
end

---@param settings table<string, table>
---@param originalCapacity number
---@param modelName string
---@param carrier string @example AIR
---@param loadType string
---@return number
local function selectCapacity(originalCapacity, settings, modelName, carrier, loadType)
  local lowerType = loadType:lower()

  if settings[modelName] then
    -- model specific override
    local modelConfig = settings[modelName]
    if type(modelConfig.capacities) == "table" then
      -- TODO support _all key as fallback for type
      if modelConfig.capacities[lowerType] then
        return modelConfig.capacities[lowerType] * 4
      end
    end
  end

  return selectFallbackMultiplier(originalCapacity, settings, carrier, loadType)
end

local function selectLoadConfigCapacity(originalCapacity, settings, modelName, carrier, loadType, index)
  local lowerType = loadType:lower()

  if settings[modelName] then
    -- model specific override
    local modelConfig = settings[modelName]
    if type(modelConfig.loadConfigs) == "table" then
      if modelConfig.loadConfigs[lowerType] then
        if type(modelConfig.loadConfigs[lowerType]) == "table" and modelConfig.loadConfigs[lowerType][index] then
          return modelConfig.loadConfigs[lowerType][index] * 4
        end
        if modelConfig.loadConfigs[lowerType] then
          return modelConfig.loadConfigs[lowerType] * 4
        end
      end
      if modelConfig.loadConfigs._all then
        if type(modelConfig.loadConfigs_all) == "table" and modelConfig.loadConfigs_all[index] then
          return modelConfig.loadConfigs_all[index] * 4
        end
        if modelConfig.loadConfigs_all then
          return modelConfig.loadConfigs_all * 4
        end
      end
    end
  end

  return selectFallbackMultiplier(originalCapacity, settings, carrier, loadType)
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
