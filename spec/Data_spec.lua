local util = require("..util.util")

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
  end)
end

describe("Data files contains all necessary information", function()
  describe("Vanilla", function()
    local files = util.dirLookup("res/scripts/grisu_correctiontorealvalues/data/vanilla")
    for _, file in ipairs(files) do
      if util.endsWith(file, ".lua") then
        checkFile(file)
      end
    end
  end)
  describe("Mods", function()
    local files = util.dirLookup("res/scripts/grisu_correctiontorealvalues/data/mods")
    for _, file in ipairs(files) do
      if util.endsWith(file, ".lua") then
        checkFile(file)
      end
    end
  end)
end)