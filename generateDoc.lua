local lfs = require("lfs")
local util = require("util.util")

local docsReadmeContent = [[
# Documentation

* [TPF2 Balancing](../Readme.md)
* Changed Data
  * Vanilla
{{ vanillaData }}
  * Mods
{{ modsData }}
]]

local typePageContent = [[
# {{ vehicleType }}
<!-- {.capitalize} -->

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
  local files = util.dirLookup(path)
  local data = {}

  for _, file in ipairs(files) do
    local vehicleType, name = string.match(file, path .. "/vehicle/(.+)/(.+).lua")
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
        vehicleType .. "]" .. "(data/" .. type .. "/" .. vehicleType .. ".md)" .. "\n"
  end
  return tocString
end

local headers = { "Vehicle", "Availability", "Lifespan", "Load Speed", "Capacity" }

local function humanReadableLifespan(lifespan)
  if lifespan > 1000 then
    return lifespan % 730.5
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
    return content .. data.metadata.name
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
      if type(origCap) == "table" then
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
      if type(newCap) == "table" then
        newCap = sumArray(newCap)
        origCap = sumArray(origCap)
      end
      rows = rows .. k .. ": " .. tostring(newCap) .. " [" .. tostring(origCap) .. "]</br>"
    end
    return content .. rows
  end
  return content
end

local function generateMdTable(typeData)
  local headersTable = {
    vehicle = {}
  }

  -- find out necessary headers
  for _, v in pairs(typeData) do
    local data = v.data

    if data.availability and not headersTable.availability then
      headersTable.availability = {}
    end
    if data.loadSpeed and not headersTable.loadSpeed then
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
    return aFrom < bFrom
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
    writeFile(basePath .. "/" .. vehicleType .. ".md", util.templateString(typePageContent, {
      vehicleType = vehicleType,
      table = generateMdTable(typeData)
    }))
  end
end

print("Creating docs directory")
util.removeDir("docs")
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

-- TODO move to own file to have support for code completion
writeFile("docs/assets/custom.css", [[
  .capitalize {
    text-transform: capitalize;
  }
]])

local vanillaData = loadData("res/scripts/grisu_correctiontorealvalues/data/vanilla")
local modData = loadData("res/scripts/grisu_correctiontorealvalues/data/mods")

generateDataFiles(vanillaData, "vanilla")
generateDataFiles(modData, "mods")

local vanillaToc = generateTocFromData(vanillaData, "    ", "vanilla")
local modToc = generateTocFromData(modData, "    ", "mods")

writeFile("docs/README.md", util.templateString(docsReadmeContent, {
  vanillaData = vanillaToc,
  modsData = modToc
}))
