--- Main
-- @author Oskar Eisemuth, Enno Sylvester (Anpassung), Benjamin Leber
-- @copyright 2017, 2018, 2019, 2020
-- @module grisu_balancing

local grisuCorrectionToRealValues = {
  version = "0.0",
  dmp = function(...)
    local ok, inspect = pcall(require, "inspect")
    if (ok) then
      print(inspect(...))
    end
  end,
}

local moduleFile = ""
local modulePath = ""
local modPath = ""

local function createLogFn(prefix)
  prefix = prefix .. ": "
  local function fn(...)
    print(table.concat({ prefix, ... }))
  end
  return fn
end

local logFn = createLogFn("grisu118_correctiontorealvalues")

local function getPath()
  local function debugPath()
    local info = debug.getinfo(1, "S")
    if (info ~= nil) then
      return string.gsub(string.gsub(info.source, '\\', '/'), '@', "")
    end
    return ""
  end
  moduleFile = debugPath()
  modulePath = string.match(moduleFile, '(.*/).*lua')
  modPath = string.match(moduleFile, "^(.*/)res/.*lua")
end

getPath()

logFn("init [", moduleFile, "] (Version ", grisuCorrectionToRealValues.version, ")")

local function doLoadFile(fileName)
  local f, err = loadfile(fileName)
  if (f ~= nil) then
    return f()
  else
    return nil, err
  end
end

-- load data lua files
local dataPrefix = modulePath .. "grisu_correctiontorealvalues/data/"
local dataMetatable = {
  __index = function(t, key)
    local configKey = string.match(key, "res/models/model/(.+).mdl")
    local vanillaFile = dataPrefix .. "vanilla/" .. configKey .. ".lua"
    local data, _ = doLoadFile(vanillaFile)
    if data then
      t[key] = data
      return t[key]
    end
    -- load mod data file
    local modFile = dataPrefix .. "mods/" .. configKey .. ".lua"
    data, _ = doLoadFile(modFile)
    if data then
      t[key] = data
      return t[key]
    end
    -- no data, return nil
    return nil
  end
}

grisuCorrectionToRealValues.data = {}
setmetatable(grisuCorrectionToRealValues.data, dataMetatable)

-- handle settings
---@class DefaultSettingsItem
---@field type string @the data type of the value
---@field default string | number | boolean @the default for the value
---@field name string @the name of the setting
---@field description string @the description of the setting

---@class Settings
---@field defaultSettings table<string, DefaultSettingsItem>
---@field settings table
local Settings = {}
Settings.__index = Settings
local settingsFile = modPath .. "settings.lua"
local capacitySettingsFile = modPath .. "capacitySettings.lua"

---@param defaultSettings table<string, DefaultSettingsItem>
local function loadSettings(defaultSettings)
  local userSettings = doLoadFile(settingsFile)
  local capacitySettings = doLoadFile(capacitySettingsFile)

  local settings = {}
  local multipliers = {
    capacity = {
      _all = {}
    }
  }
  settings.multipliers = multipliers

  for k, defaultItem in pairs(defaultSettings) do
    local value
    if userSettings and userSettings[k] and type(userSettings[k]) == defaultItem.type then
      -- use value from userSettings
      value = userSettings[k]
    else
      -- use default value
      value = defaultItem.default
    end
    if k == "loadSpeedMultiplier" then
      multipliers.loadSpeed = value
    elseif k == "lifespanMultiplier" then
      multipliers.lifespan = value
    elseif k == "powerMultiplier" then
      multipliers.power = value
    elseif k == "passengerCapacityMultiplier" then
      multipliers.capacity._all.passengers = value
    elseif k == "cargoCapacityMultiplier" then
      multipliers.capacity._all._all = value
    end
  end

  -- override capacity settings from own file
  if type(capacitySettings) == "table" then
    for vehicleType, typeTable in pairs(capacitySettings) do
      if type(multipliers.capacity[vehicleType]) ~= table then
        multipliers.capacity[vehicleType] = {}
      end
      for cargoType, multiplier in pairs(typeTable) do
        multipliers.capacity[vehicleType][cargoType] = multiplier
      end
    end
  end

  return settings
end

---@param defaultSettings table<string, DefaultSettingsItem>
function Settings.create(defaultSettings)
  local obj = {}
  setmetatable(obj, Settings)
  obj.defaultSettings = defaultSettings
  obj.settings = loadSettings(defaultSettings)
  return obj
end

grisuCorrectionToRealValues.settings = Settings


-- load update lua files
local grisuCorrectionToRealValuesMetatable = {
  __index = function(t, key)
    local fileName = modulePath .. "grisu_correctiontorealvalues/" .. key .. ".lua"
    local data, err = doLoadFile(fileName)
    if data then
      t[key] = data
      t[key].grisu_balancing = grisuCorrectionToRealValues
      logFn("loaded module 'grisu118_correctiontorealvalues.",
          key,
          "' [", fileName, "] (Version ", data.version or "0.0", ")")
      return t[key]
    else
      logFn("can not load module 'grisu118_correctiontorealvalues.", key, "'. Message: ", (err or ""))
      return nil
    end
  end
}
setmetatable(grisuCorrectionToRealValues, grisuCorrectionToRealValuesMetatable)

return grisuCorrectionToRealValues