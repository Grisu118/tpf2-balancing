--- RailVehicle
-- @author Benjamin Leber
-- @copyright 2019, 2020
-- @module grisu_balancing.capacities

---@class RailVehicle
---@field balancingData BalancingData
---@field modelName string
local RailVehicle = {}
RailVehicle.__index = RailVehicle

---@public
---@param balancingData BalancingData
---@param modelName string @the path to the mdl of the model, starting with res/
---@return RailVehicle the newly created rail vehicle object
function RailVehicle.create(modelName, balancingData)
  local cap = {}
  setmetatable(cap, RailVehicle)
  cap.modelName = modelName
  cap.balancingData = balancingData
  return cap
end
-- TODO Handle other vehicles
---@public
---@param railVehicle table
function RailVehicle:update(railVehicle)
  if self.balancingData[self.modelName] then
    local modelConfig = self.balancingData[self.modelName]
    if type(modelConfig.railVehicle) ~= "table" then
      return
    end
    if modelConfig.railVehicle.topSpeed then
      -- set top speed in m/s, config value is in km/h
      railVehicle.topSpeed = modelConfig.railVehicle.topSpeed / 3.6
    end
    if modelConfig.railVehicle.weight then
      railVehicle.weight = modelConfig.railVehicle.weight
    end
    -- update engines
    if modelConfig.railVehicle.engines then
      if not railVehicle.engines then
        railVehicle.engines = {}
      end
      self:updateEngines(railVehicle.engines, modelConfig.railVehicle.engines)
    end
  else
    -- apply power factor
    if railVehicle.engines then
      for _, engine in ipairs(railVehicle.engines) do
        if engine.power then
          engine.power = engine.power * self.balancingData._multipliers.power
        end
        if engine.tractiveEffort then
          engine.tractiveEffort = engine.tractiveEffort * self.balancingData._multipliers.power
        end
      end
    end
  end
end

---@private
function RailVehicle:updateEngines(vehicleEngines, engineConfig)
  -- no array given, apply values to every engine of the vehicle
  if engineConfig.power or engineConfig.tractiveEffort then
    for _, engine in ipairs(vehicleEngines) do
      if engineConfig.power then
        engine.power = engineConfig.power * self.balancingData._multipliers.power
      end
      if engineConfig.tractiveEffort then
        engine.tractiveEffort = engineConfig.tractiveEffort * self.balancingData._multipliers.power
      end
    end
  else
    -- array given, length of both must be equal
    if #vehicleEngines ~= #engineConfig then
      error("Engine block config must be the same length: " .. self.modelName)
    end
    for i, eConfig in ipairs(engineConfig) do
      local engine = vehicleEngines[i]
      if eConfig.power then
        engine.power = eConfig.power * self.balancingData._multipliers.power
      end
      if eConfig.tractiveEffort then
        engine.tractiveEffort = eConfig.tractiveEffort * self.balancingData._multipliers.power
      end
    end
  end
end

return RailVehicle