local fileUtil = require("..util.file")
local stringUtil = require("..util.string")

local function checkFile(file)
  describe(file, function()
    local f = loadfile(file)
    local data = f()
    it("data is table", function()
      assert.are.equals("table", type(data))
    end)
    it("data.metadata is table", function()
      assert.are.equals("table", type(data.metadata))
    end)
    it("data.metadata.name is string", function()
      assert.are.equals("string", type(data.metadata.name))
    end)
    it("data.metadata.name is not an empty string", function()
      assert.is_true(string.len(data.metadata.name) > 0)
    end)
    -- require metadata.availability.yearFrom for sorting in doc table
    it("data.metadata.availability is table", function()
      assert.are.equals("table", type(data.metadata.availability))
    end)
    it("data.metadata.availability.yearFrom is number", function()
      assert.are.equals("number", type(data.metadata.availability.yearFrom))
    end)
    if data.loadSpeed then
      it("data.loadSpeed is a number", function()
        assert.are.equals("number", type(data.loadSpeed))
      end)
      it("data.metadata.loadSpeed is a number", function()
        assert.are.equals("number", type(data.metadata.loadSpeed))
      end)
    end
    if data.maintenance then
      it("data.maintenance is a table", function()
        assert.are.equals("table", type(data.maintenance))
      end)
      it("data.metadata.maintenance is a table", function()
        assert.are.equals("table", type(data.metadata.maintenance))
      end)
      if data.maintenance.lifespan then
        it("data.maintenance.lifespan is a number", function()
          assert.are.equals("number", type(data.maintenance.lifespan))
        end)
        it("data.metadata.maintenance.lifespan is a number", function()
          assert.are.equals("number", type(data.metadata.maintenance.lifespan))
        end)
      end
    end
    if data.availability then
      it("data.availability is a table", function()
        assert.are.equals("table", type(data.availability))
      end)
      it("data.metadata.availability is a table", function()
        assert.are.equals("table", type(data.metadata.availability))
      end)
      if data.availability.yearFrom then
        it("data.availability.yearFrom is a number", function()
          assert.are.equals("number", type(data.availability.yearFrom))
        end)
        it("data.metadata.availability.yearFrom is a number", function()
          assert.are.equals("number", type(data.metadata.availability.yearFrom))
        end)
      end
      if data.availability.yearTo then
        it("data.availability.yearTo is a number", function()
          assert.are.equals("number", type(data.availability.yearTo))
        end)
        it("data.metadata.availability.yearTo is a number", function()
          assert.are.equals("number", type(data.metadata.availability.yearTo))
        end)
      end
    end
    if data.capacities then
      it("data.capacities is a table", function()
        assert.are.equals("table", type(data.capacities))
      end)
      it("data.metadata.capacities is a table", function()
        assert.are.equals("table", type(data.metadata.capacities))
      end)
    end
    if data.loadConfigs then
      it("data.loadConfigs is a table", function()
        assert.are.equals("table", type(data.loadConfigs))
      end)
      it("data.metadata.capacities is a table", function()
        assert.are.equals("table", type(data.metadata.capacities))
      end)
    end
    if data.railVehicle then
      it("data.railVehicle is a table", function()
        assert.are.equals("table", type(data.railVehicle))
      end)
      it("data.metadata.railVehicle is a table", function()
        assert.are.equals("table", type(data.metadata.railVehicle))
      end)
      if data.railVehicle.topSpeed then
        it("data.railVehicle.topSpeed is a number", function()
          assert.are.equals("number", type(data.railVehicle.topSpeed))
        end)
        it("data.metadata.railVehicle.topSpeed is a number", function()
          assert.are.equals("number", type(data.metadata.railVehicle.topSpeed))
        end)
      end
      if data.railVehicle.weight then
        it("data.railVehicle.weight is a number", function()
          assert.are.equals("number", type(data.railVehicle.weight))
        end)
        it("data.metadata.railVehicle.weight is a number", function()
          assert.are.equals("number", type(data.metadata.railVehicle.weight))
        end)
      end
      if data.railVehicle.engines then
        it("data.railVehicle.engines is a table", function()
          assert.are.equals("table", type(data.railVehicle.engines))
        end)
        it("data.metadata.railVehicle.engines is a table", function()
          assert.are.equals("table", type(data.metadata.railVehicle.engines))
        end)
        if data.railVehicle.engines.power or data.railVehicle.engines.tractiveEffort then
          if data.railVehicle.engines.power then
            it("data.railVehicle.engines.power is a number", function()
              assert.are.equals("number", type(data.railVehicle.engines.power))
            end)
            it("data.metadata.railVehicle.engines.power is a number", function()
              assert.are.equals("number", type(data.metadata.railVehicle.engines.power))
            end)
          end
          if data.railVehicle.engines.tractiveEffort then
            it("data.railVehicle.engines.tractiveEffort is a number", function()
              assert.are.equals("number", type(data.railVehicle.engines.tractiveEffort))
            end)
            it("data.metadata.railVehicle.engines.tractiveEffort is a number", function()
              assert.are.equals("number", type(data.metadata.railVehicle.engines.tractiveEffort))
            end)
          end
        else
          -- both tables have the same length
          it("data.metadata.railVehicle.engines and data.railVehicle.engines have the same length", function()
            assert.are.equals(#data.railVehicle.engines, #data.metadata.railVehicle.engines)
          end)
        end
      end
    end
  end)
end

describe("Data files contains all necessary information", function()
  describe("Vanilla", function()
    local files = fileUtil.dirLookup("res/scripts/grisu_correctiontorealvalues/data/vanilla")
    for _, file in ipairs(files) do
      if stringUtil.endsWith(file, ".lua") then
        checkFile(file)
      end
    end
  end)
  describe("Mods", function()
    local files = fileUtil.dirLookup("res/scripts/grisu_correctiontorealvalues/data/mods")
    for _, file in ipairs(files) do
      if stringUtil.endsWith(file, ".lua") then
        checkFile(file)
      end
    end
  end)
end)