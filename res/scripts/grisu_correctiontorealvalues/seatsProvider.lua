--- SeatsProvider
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.seatsProvider

---@class SeatsProvider
---@field balancingData BalancingData
---@field modelName string
local SeatsProvider = {}
SeatsProvider.__index = SeatsProvider

---@public
---@param balancingData BalancingData
---@param modelName string @the path to the mdl of the model, starting with res/
---@return SeatsProvider the newly created capacities object
function SeatsProvider.create(modelName, balancingData)
  local cap = {}
  setmetatable(cap, SeatsProvider)
  cap.modelName = modelName
  cap.balancingData = balancingData
  return cap
end

---@public
---@param metadata table
function SeatsProvider:update(metadata)
  if self.balancingData[self.modelName] then
    local modelConfig = self.balancingData[self.modelName]
    if type(modelConfig.additionalSeats) == "table" then
      if type(metadata.seatProvider) ~= "table" or type(metadata.seatProvider.seats) ~= table then
        -- we can only append seats to an existing provider
        return
      end
      for _, seat in ipairs(modelConfig.additionalSeats) do
        table.insert(metadata.seatProvider.seats, seat)
      end
    end
  end
end

return SeatsProvider