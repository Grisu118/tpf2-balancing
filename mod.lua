local balancing = require "grisu_correctiontorealvalues"
---@type Modifiers
local modifiers = balancing.modifiers

---@class Fallbacks
-- TODO extend with settings similar to merk_modutil
local defaultSettings = {
  -- capacity multipliers
  multipliers = {
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
      local balancingData = balancing.data
      balancingData._multipliers = defaultSettings.multipliers

      addModifier("loadModel", function(fileName, data)
        return modifiers.loadModel(fileName, data, balancingData)
      end)
    end
  }
end
