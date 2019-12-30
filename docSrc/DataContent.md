# Data Modification Files

This file explains the different values you can provide in a vehicle config file.
The following file shows all possible values. See the comments in the file for details. 

```lua
return {
  -- information about the original vehicle, used to generate the documentation
  metadata = {
    name = "SBB Roterpfeil",
    loadSpeed = 1,
    -- the original capacities, also used if vehicle as loadConfigs
    capacities = { 
      passengers = 80,
      _all = 70
    },
    availability = {
      yearFrom = 1935, -- this is mandatory for every config, as it is used for sorting the vehicles in the documentation
      yearTo = 1992,
    },
    railVehicle = {
      engines = { -- can also be an array if multiple engines are present
        power = 809,
        tractiveEffort = 177,
      },
      topSpeed = 25, -- speed in m/s as it is in the game
      weight = 62,
    },
    maintenance = {
      lifespan = 29568 -- lifespan as it is in the game
    }
  },
  loadConfigs = { -- can also be an array, if there are multiple entries
    -- Real: 70 seats, 30 standing
    passengers = 80, -- specific config for passengers
    coal = 55, -- specific config for coal
    _all = 50  -- fallback for all other cargo types
  },
  railVehicle = {
    engines = {
        power = 800,
        tractiveEffort = 175,
    },
    topSpeed = 30, -- speed in km/h
    weight = 60,
  },
  maintenance = {
    lifespan = 30 -- lifespan in years
  },
  availability = {
    yearFrom = 1935,
    yearTo = 1992,
  }
}
```

## LoadConfigs / Capacities

### Capacities

The capacities block cannot be an array (only in metadata it can), if the original vehicle has multiple compartments.
The capacity of each compartment is set to the value given in capacities. In this case the metadata.capacities.type must be an array.
Otherwise the documentation shows wrong values.
[Example](https://github.com/Grisu118/tpf2-balancing/blob/master/res/scripts/grisu_correctiontorealvalues/data/vanilla/vehicle/plane/bristol_freighter.lua)

### LoadConfigs

[Example](https://github.com/Grisu118/tpf2-balancing/blob/master/res/scripts/grisu_correctiontorealvalues/data/vanilla/vehicle/plane/junkers_ju_52.lua)