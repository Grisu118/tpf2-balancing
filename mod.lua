local balancing = require "grisu_balancing"
---@type Modifiers
local modifiers = balancing.modifiers

---@class Fallbacks
local defaultSettings = {
  -- capacity multipliers
  multipliers = {
    air = {
      passengers = 4,
      coal = 2.5,
      _all = 2.5
    },
    _all = {
      passengers = 4,
      _all = 2.5
    }
  }
}

function data()
  return {
    info = {
      minorVersion = 1,
      severityAdd = "NONE",
      severityRemove = "NONE",
      name = "Grisu's Balancing",
      description = "TODO",
      authors = {
        {
          name = "Grisu118",
          role = "CREATOR",
          text = ""
        }
      },
      tags = { "Script Mod" },
      modid = "grisu118_balancing_0"
    },
    runFn = function()
      local balancingData = balancing.data
      balancingData._fallbacks = defaultSettings

      addModifier("loadModel", function(fileName, data)
        return modifiers.loadModel(fileName, data, balancingData)
      end)
    end
  }
end
