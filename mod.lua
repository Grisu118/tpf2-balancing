local balancing = require "grisu_correctiontorealvalues"
---@type Capacities
local Capacities = balancing.capacities
---@type LoadSpeed
local LoadSpeed = balancing.loadSpeed
---@type Availability
local Availability = balancing.availability

---@class BalancingData : table
---@field _multipliers Multipliers

---@class Fallbacks
-- TODO extend with settings similar to merk_modutil
local defaultSettings = {
  -- capacity multipliers
  ---@class Multipliers
  ---@field loadSpeed number
  ---@field capacity table
  multipliers = {
    loadSpeed = 1,
    capacity = {
      air = {
        passengers = 4,
        coal = 3,
        _all = 3
      },
      _all = {
        passengers = 4,
        _all = 3
      }
    }
  }
}

function data()
  return {
    info = {
      minorVersion = 0,
      severityAdd = "NONE",
      severityRemove = "NONE",
      name = "Grisu's Balancing to real values",
      description = "TODO",
      authors = {
        {
          name = "Grisu118",
          role = "CREATOR",
          tfnetId = "18977",
          text = ""
        }
      },
      tags = { "Script Mod" },
    },
    runFn = function()
      ---@type BalancingData
      local balancingData = balancing.data
      balancingData._multipliers = defaultSettings.multipliers

      ---@param fileName string the name of the .mdl file which is loaded
      ---@param data any the data returned from the data function in the mdl file
      addModifier("loadModel", function(fileName, data)
        if type(data.metadata) == "table" then
          local modelName = string.gsub(fileName, ".*(res/models/model/.+[.]mdl)", "%1")

          if type(data.metadata.transportVehicle) == "table" then
            local transportVehicle = data.metadata.transportVehicle
            -- handle capacities
            local capacities = Capacities.create(modelName, balancingData)
            capacities:update(transportVehicle)

            -- handle loadSpeed
            local loadSpeed = LoadSpeed.create(modelName, balancingData)
            loadSpeed:update(transportVehicle)
          end

          local availability = Availability.create(modelName, balancingData)
          availability:update(data.metadata)

        end
        return data
      end)
    end
  }
end
