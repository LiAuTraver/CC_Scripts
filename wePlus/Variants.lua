-- Properties for different block variants.
local Variants = {}

local Common = require("wePlus.Common")

Variants.log = {
  axis = Common:axis(),
}

Variants.stripped_log = {
  axis = Common:axis(),
}

Variants.wood = {
  axis = Common:axis(),
}

Variants.stripped_wood = {
  axis = Common:axis(),
}

Variants.fence = {
  east = Common:boolean(),
  north = Common:boolean(),
  south = Common:boolean(),
  west = Common:boolean(),
  waterlogged = Common:boolean()
}

Variants.fence_gate = {
  facing = Common:directions(),
  in_wall = Common:boolean(),
  open = Common:boolean(),
  powered = Common:boolean()
}

Variants.wall_sign = {
  facing = Common:directions(),
  waterlogged = Common:boolean()
}

Variants.sign = {
  rotation = Common:numbers(16),
  waterlogged = Common:boolean()
}

Variants.wall_hanging_sign = {
  facing = Common:directions(),
  waterlogged = Common:boolean()
}

Variants.hanging_sign = {
  attached = Common:boolean(),
  rotation = Common:numbers(16),
  waterlogged = Common:boolean()
}

-- ^^^ Log Variants ^^^ / vvv Stone Variants vvv

Variants.wall = {
  east = { "low", "none", "tall" },
  north = { "low", "none", "tall" },
  south = { "low", "none", "tall" },
  west = { "low", "none", "tall" },
  waterlogged = Common:boolean(),
  up = Common:boolean()
}

-- ^^^ Stone Variants ^^^ / vvv Universal Variants vvv

Variants.stairs = {
  shape = { "straight", "inner_left", "inner_right", "outer_left", "outer_right" },
  facing = Common:directions(),
  half = { "top", "bottom" },
  waterlogged = Common:boolean()
}

Variants.slab = {
  type = { "top", "bottom", "double" },
  waterlogged = Common:boolean()
}

Variants.door = {
  facing = Common:directions(),
  half = { "upper", "lower" },
  hinge = { "left", "right" },
  powered = Common:boolean(),
  open = Common:boolean()
}

Variants.trapdoor = {
  facing = Common:directions(),
  half = { "top", "bottom" },
  waterlogged = Common:boolean(),
  open = Common:boolean(),
  powered = Common:boolean()
}

Variants.button = {
  face = { "ceiling", "floor", "wall" },
  facing = Common:directions(),
  powered = Common:boolean()
}

return Variants
