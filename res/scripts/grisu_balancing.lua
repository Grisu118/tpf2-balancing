--- Main
-- @author Oskar Eisemuth, Enno Sylvester (Anpassung), Benjamin Leber
-- @copyright 2017, 2018, 2019, 2020
-- @module grisu_balancing

local grisu_balancing = {
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

local logFn = createLogFn("grisu_balancing")

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

logFn("init [", moduleFile, "] (Version ", grisu_balancing.version, ")")

local function doLoadFile(fileName)
  local f, err = loadfile(fileName)
  if (f ~= nil) then
    return f()
  else
    return nil, err
  end
end

local data_prefix = modulePath .. "grisu_balancing/data/"

local data_metatable = {
  __index = function(t, key)
    local configKey = string.match(key, "res/models/model/(.+).mdl")
    local vanillaFile = data_prefix .. "vanilla/" .. configKey .. ".lua"
    local data, err = doLoadFile(vanillaFile)
    if data then
      t[key] = data
      return t[key]
    end
    -- load mod data file
    local modFile = data_prefix .. "mods/" .. configKey .. ".lua"
    data, err = doLoadFile(modFile)
    if data then
      t[key] = data
      return t[key]
    end
    -- no data, return nil
    return nil
  end
}

grisu_balancing.data = {}
setmetatable(grisu_balancing.data, data_metatable)

local grisu_balancing_metatable = {
  __index = function(t, key)
    local fileName = modulePath .. "grisu_balancing/" .. key .. ".lua"
    local data, err = doLoadFile(fileName)
    if data then
      t[key] = data
      t[key].grisu_balancing = grisu_balancing
      logFn("loaded module 'grisu_balancing.", key, "' [", fileName, "] (Version ", data.version or "0.0", ")")
      return t[key]
    else
      logFn("can not load module 'grisu_balancing.", key, "'. Message: ", (err or ""))
      return nil
    end
  end
}
setmetatable(grisu_balancing, grisu_balancing_metatable)

return grisu_balancing