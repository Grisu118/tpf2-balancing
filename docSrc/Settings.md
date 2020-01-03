# Settings

## Mod Settings (CommonAPI2 or TPFMM)
[See also](https://www.transportfever.net/lexikon/index.php/Entry/217-Settings-for-Mods/)</br>
[Siehe auch](https://www.transportfever.net/lexikon/index.php/Entry/216-Einstellungen-f%C3%BCr-Mods/)

Use common api or tpfmm (as soon as available) for customization.
You can also copy the following to a file named `settings.lua` into the mods main directory.

````lua
return {
	passengerCapacityMultiplier = 4,
	cargoCapacityMultiplier = 3,
	lifespanMultiplier = 1,
	loadSpeedMultiplier = 1,
	powerMultiplier = 1,
}
````
The file shows the active default settings. 

## Extended Capacity Configuration

It is also possible to customize the capacity multipliers for every vehicle type and cargo.
To do so you need to create a file named `capacitySettings.lua` in the mods main directory.

The file needs the following structure:
````lua
return {
  <vehicleType> = {
    <cargoType> = <multiplier
  }
}
````

Example file
````lua
return {
  air = {
    passengers = 4,
    coal = 2.5,
    _all = 3
  },
  _all = {
    passengers = 4,
    _all = 3
  }
}
````

The `vehicleType` and `cargoType` must be written in lowercase.
The `vehicleType` comes from the `transportVehicle.carrier` in the mdl. 
The `cargoType` comes from the `type` in the compartments or loadConfigs list.

You can always us the `_all` key as fallback for all values which are not in the current list.
The last `_all` fallback in the example above is optional, this is always created from the Mod Settings.