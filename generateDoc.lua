local lfs = require("lfs")
local stringUtil = require("util.string")
local fileUtil = require("util.file")

local docsReadmeContent = [[
# Documentation

* [TPF2 Balancing](../Readme.md)
* [Settings](./Settings.md)
* Changed Data
  * [Available Modifications](./DataContent.md)
  * Vanilla
{{ vanillaData }}
  * Mods
{{ modsData }}
]]

local typePageContent = [[
# {{ vehicleType }}

The following table lists the changes made with this balancing.
The new values are the first, the original ones are written in square brackets ([])

{{ table }}
]]

local function writeFile(file, content)
  local f = io.open(file, "w")
  f:write(content)
  f:close()
end

local function loadData(path)
  -- scan vanilla directory for data
  local files = fileUtil.dirLookup(path)
  local data = {}

  for _, file in ipairs(files) do
    local vehicleType, name = string.match(file, path .. "/vehicle/([a-zA-Z0-9_\\-]+)/(.+).lua")
    if vehicleType and name then
      if not data[vehicleType] then
        data[vehicleType] = {}
      end
      if data[vehicleType][name] then
        print(file)
        print(vehicleType, name)
        error("Name already defined for type")
      end
      local f = loadfile(file)
      data[vehicleType][name] = {
        file = file,
        data = f()
      }
    end
  end
  return data
end

local function generateTocFromData(data, baseIntend, type)
  local tocString = ""
  for vehicleType, _ in pairs(data) do
    tocString = tocString .. baseIntend .. "* [" ..
      stringUtil.firstToUpper(vehicleType) .. "]" .. "(data/" .. type .. "/" .. vehicleType .. ".md)" .. "\n"
  end
  return tocString
end

local headers = { "Vehicle",
                  "Source",
                  "Availability",
                  "Lifespan",
                  "Load Speed",
                  "Capacity",
                  "Top Speed",
                  "Weight",
                  "Engines"
}

local function humanReadableLifespan(lifespan)
  if lifespan > 1000 then
    return lifespan / 730.5
  end
  return lifespan
end

local function sumArray(numberArray)
  local sum = 0
  for _, v in pairs(numberArray) do
    sum = sum + v
  end
  return sum
end

local function generateMdCell(typeData, header)
  local content = "| "
  local data = typeData.data
  if header == "Vehicle" then
    return content .. "[" .. data.metadata.name ..
      "](https://github.com/Grisu118/tpf2-balancing/blob/master/" .. typeData.file .. ")"
  end
  if header == "Source" then
    if data.metadata.source.tpfnet then
      content = content .. "[TPF.net](https://www.transportfever.net/filebase/index.php/Entry/" ..
        tostring(data.metadata.source.tpfnet) .. ") "
    end
    if data.metadata.source.steam then
      content = content .. "[Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=" ..
        tostring(data.metadata.source.steam) .. ") "
    end
    if data.metadata.source.other then
      content = content .. "[Other](" .. tostring(data.metadata.source.other) .. ") "
    end
    return content
  end
  if header == "Availability" and data.availability then
    local yearFrom = data.availability.yearFrom
    local yearTo = data.availability.yearTo

    if type(yearFrom) == "number" then
      content = content .. tostring(yearFrom) .. " [" .. data.metadata.availability.yearFrom .. "]"
    else
      content = content .. "?"
    end
    content = content .. " - "
    if type(yearTo) == "number" then
      content = content .. tostring(yearTo) .. " [" .. data.metadata.availability.yearTo .. "]"
    else
      content = content .. "?"
    end
    return content
  end
  if header == "Load Speed" and data.loadSpeed then
    return content .. data.loadSpeed .. " [" .. data.metadata.loadSpeed .. "]"
  end
  if header == "Lifespan" and data.maintenance and data.maintenance.lifespan then
    return content .. humanReadableLifespan(data.maintenance.lifespan) ..
      "y [" .. humanReadableLifespan(data.metadata.maintenance.lifespan) .. "]"
  end
  if header == "Capacity" and data.capacities then
    local rows = ""
    for k in pairs(data.capacities) do
      local newCap = data.capacities[k]
      local origCap = data.metadata.capacities[k]
      if origCap == nil then
        origCap = data.metadata.capacities._all
      end
      if type(newCap) == "table" and type(origCap) == "table" then
        newCap = sumArray(newCap)
        origCap = sumArray(origCap)
      elseif type(origCap) == "table" then
        newCap = newCap * #origCap
        origCap = sumArray(origCap)
      end
      rows = rows .. k .. ": " .. tostring(newCap) .. " [" .. tostring(origCap) .. "]</br>"
    end
    return content .. rows
  end
  if header == "Capacity" and data.loadConfigs then
    local rows = ""
    for k in pairs(data.loadConfigs) do
      local newCap = data.loadConfigs[k]
      local origCap = data.metadata.capacities[k]
      if origCap == nil then
        origCap = data.metadata.capacities._all
      end
      if type(newCap) == "table" then
        newCap = sumArray(newCap)
        origCap = sumArray(origCap)
      end
      rows = rows .. k .. ": " .. tostring(newCap) .. " [" .. tostring(origCap) .. "]</br>"
    end
    return content .. rows
  end
  -- vehicleConfig
  local vehicleConfig = {}
  local vehicleMeta = {}
  if data.railVehicle then
    vehicleConfig = data.railVehicle
    vehicleMeta = data.metadata.railVehicle
  end
  if data.roadVehicle then
    vehicleConfig = data.roadVehicle
    vehicleMeta = data.metadata.roadVehicle
  end
  if header == "Top Speed" and vehicleConfig.topSpeed then
    return content .. tostring(vehicleConfig.topSpeed) ..
      "km/h [" .. tostring(vehicleMeta.topSpeed * 3.6) .. "]"
  end
  if header == "Weight" and vehicleConfig.weight then
    return content .. tostring(vehicleConfig.weight) ..
      "t [" .. tostring(vehicleMeta.weight) .. "]"
  end
  if header == "Engines" and vehicleConfig.engines then
    local rows = ""
    -- single entry
    if vehicleConfig.engines.power or vehicleConfig.engines.tractiveEffort then
      if vehicleConfig.engines.power then
        rows = rows .. "Power: " .. tostring(vehicleConfig.engines.power) ..
          " [" .. tostring(vehicleMeta.engines.power) .. "]</br>"
      end
      if vehicleConfig.engines.tractiveEffort then
        rows = rows .. "<span title=\"tractive effort\">TrEffort</span>: " ..
          tostring(vehicleConfig.engines.tractiveEffort) ..
          " [" .. tostring(vehicleMeta.engines.tractiveEffort) .. "]</br>"
      end
    else
      for i, engine in ipairs(vehicleConfig.engines) do
        if engine.power then
          rows = rows .. "Power: " .. tostring(engine.power) ..
            " [" .. tostring(vehicleMeta.engines[i].power) .. "]</br>"
        end
        if engine.tractiveEffort then
          rows = rows .. "<span title=\"tractive effort\">TrEffort</span>: " ..
            tostring(engine.tractiveEffort) ..
            " [" .. tostring(vehicleMeta.engines[i].tractiveEffort) .. "]</br>"
        end
      end
    end
    return content .. rows
  end
  return content
end

local function generateMdTable(typeData, isMod)
  local headersTable = {
    vehicle = {}
  }
  if isMod then
    headersTable.source = {}
  end

  -- find out necessary headers
  for _, v in pairs(typeData) do
    local data = v.data
    if data.availability and not headersTable.availability then
      headersTable.availability = {}
    end
    if data.loadSpeed and not headersTable["load speed"] then
      headersTable["load speed"] = {}
    end
    if data.maintenance then
      if data.maintenance.lifespan and not headersTable.lifespan then
        headersTable.lifespan = {}
      end
    end
    if data.capacities or data.loadConfigs then
      headersTable.capacity = {}
    end
    if data.railVehicle then
      if data.railVehicle.topSpeed and not headersTable["top speed"] then
        headersTable["top speed"] = {}
      end
      if data.railVehicle.weight and not headersTable.weight then
        headersTable.weight = {}
      end
      if data.railVehicle.engines and not headersTable.engines then
        headersTable.engines = {}
      end
    end
    if data.roadVehicle then
      if data.roadVehicle.topSpeed and not headersTable["top speed"] then
        headersTable["top speed"] = {}
      end
      if data.roadVehicle.weight and not headersTable.weight then
        headersTable.weight = {}
      end
      if data.roadVehicle.engines and not headersTable.engines then
        headersTable.engines = {}
      end
    end
  end

  local content = ""
  local secondLine = ""

  for _, v in ipairs(headers) do
    if headersTable[v:lower()] then
      content = content .. "| " .. v .. " "
      secondLine = secondLine .. "| --- "
    end
  end
  content = content .. "\n"
  content = content .. secondLine
  content = content .. "\n"

  local dataArray = {}
  for _, v in pairs(typeData) do
    table.insert(dataArray, v)
  end
  table.sort(dataArray, function(a, b)
    local aFrom = a.data.metadata.availability.yearFrom
    if a.data.availability and a.data.availability.yearFrom then
      aFrom = a.data.availability.yearFrom
    end
    local bFrom = b.data.metadata.availability.yearFrom
    if b.data.availability and b.data.availability.yearFrom then
      bFrom = b.data.availability.yearFrom
    end
    if aFrom == bFrom then
      return a.data.metadata.name < b.data.metadata.name
    else
      return aFrom < bFrom
    end
  end)

  for _, data in ipairs(dataArray) do
    local row = ""
    for _, header in ipairs(headers) do
      if headersTable[header:lower()] then
        row = row .. generateMdCell(data, header)
      end
    end
    content = content .. row .. "\n"
  end

  return content
end

local function generateDataFiles(data, type)
  local basePath = "docs/data/" .. type
  for vehicleType, typeData in pairs(data) do
    writeFile(basePath .. "/" .. vehicleType .. ".md", stringUtil.templateString(typePageContent, {
      vehicleType = stringUtil.firstToUpper(vehicleType),
      table = generateMdTable(typeData, type == "mods")
    }))
  end
end

print("Creating docs directory")
fileUtil.removeDir("docs")
lfs.mkdir("docs")
lfs.mkdir("docs/data")
lfs.mkdir("docs/assets")
lfs.mkdir("docs/data/vanilla/")
lfs.mkdir("docs/data/mods/")
writeFile("docs/docpress.json", [[
{
  "github": "Grisu118/tpf2-balancing",
  "css": [
    "docs/assets/custom.css"
  ],
  "markdown": {
    "typographer": true,
    "plugins": {
      "decorate": {}
    }
  }
}
]])

-- copy static files
print("Copy static files")
fileUtil.copyFile("docSrc/assets/custom.css", "docs/assets/custom.css")
fileUtil.copyFile("docSrc/DataContent.md", "docs/DataContent.md")
fileUtil.copyFile("docSrc/Settings.md", "docs/Settings.md")

local vanillaData = loadData("res/scripts/grisu_correctiontorealvalues/data/vanilla")
local modData = loadData("res/scripts/grisu_correctiontorealvalues/data/mods")

generateDataFiles(vanillaData, "vanilla")
generateDataFiles(modData, "mods")

local vanillaToc = generateTocFromData(vanillaData, "    ", "vanilla")
local modToc = generateTocFromData(modData, "    ", "mods")

print("Write ToC")
writeFile("docs/README.md", stringUtil.templateString(docsReadmeContent, {
  vanillaData = vanillaToc,
  modsData = modToc
}))
