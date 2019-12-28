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