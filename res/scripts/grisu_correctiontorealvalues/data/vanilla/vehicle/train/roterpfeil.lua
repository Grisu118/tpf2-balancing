return {
  -- TODO Should we fix the train driver? Both are visible when driving forward, none when driving backwards
  metadata = {
    name = "SBB Roterpfeil",
    loadSpeed = 1,
    capacities = {
      passengers = 80
    },
  },
  loadConfigs = {
    -- Real: 70 seats, 30 standing
    passengers = 80
  },
}