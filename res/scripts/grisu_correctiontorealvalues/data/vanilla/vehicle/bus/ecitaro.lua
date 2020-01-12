return {
  metadata = {
    name = "eCitaro",
    loadSpeed = 5,
    capacities = {
      passengers = 68
    },
    availability = {
      yearFrom = 2019,
      yearTo = 0,
    }
  },
  capacities = {
    -- Real:
    -- sitting 37, idle 2+6
    passengers = 45
  },
  loadSpeed = 3,
  additionalSeats = {
    {
      animation = "idle",
      crew = false,
      forward = true,
      group = 14,
      transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1.1, 0.0, 0.33799999952316, 1, },
    },
    {
      animation = "idle",
      crew = false,
      forward = true,
      group = 14,
      transf = { -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0.45, 0.0, 0.33799999952316, 1, },
    },
    {
      animation = "idle",
      crew = false,
      forward = true,
      group = 14,
      transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -0.4, 0.0, 0.33799999952316, 1, },
    },
    {
      animation = "idle",
      crew = false,
      forward = true,
      group = 14,
      transf = { 0.985, 0.174, 0, 0, -0.174, 0.985, 0, 0, 0, 0, 1, 0,
                 -1.4919999837875, -0.76399999856949, 0.33799999952316, 1, },
    },
    {
      animation = "idle",
      crew = false,
      forward = true,
      group = 14,
      transf = { -0.996, -0.087, 0, 0, 0.087, -0.996, 0, 0, 0, 0, 1, 0, -0.7, -0.76399999856949, 0.33799999952316, 1, },
    },
    {
      animation = "idle",
      crew = false,
      forward = true,
      group = 14,
      transf = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2.5, 0.0, 0.33799999952316, 1, },
    }
  }
}