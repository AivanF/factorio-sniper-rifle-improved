local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = "lightning-rod-3-mighty"
local icon = "__Lightning__/graphics/icons/3mighty.png"
local icon_size = 64
local icon_mipmaps = 3
local acc_capacity = 10000

data:extend({
  {
    type = "item",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-rod-3]",
    place_result = name,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = {
      {"steel-plate", 2000},
      {"copper-plate", 1000},
      {"coal", 200},
      {"plastic-bar", 400},
      {"battery", 2000},
      {"processing-unit", 100},
    },
    result = name,
  },
  {
    type = "accumulator",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.75, mining_time = 2, result = name},
    max_health = 5000,
    resistances = {
      { type = "physical", decrease=50, percent=50 },
      { type = "impact", decrease=50, percent=50 },
      { type = "fire", decrease=50, percent=50 },
      { type = "acid", decrease=20, percent=20 },
      { type = "poison", decrease=200, percent=99 },
      { type = "explosion", decrease=50, percent=50 },
      { type = "laser", decrease=20, percent=20 },
      { type = "electric", decrease=80, percent=80 },
    },
    collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
    selection_box = {{-3, -3}, {3, 3}},
    corpse = "big-electric-pole-remnants",
    dying_explosion = "medium-explosion",
    energy_source = {
      type = "electric",
      usage_priority = "primary-output",
      input_flow_limit = "0KW",
      output_flow_limit = "500MW",
      buffer_capacity = acc_capacity.."MJ"
    },
    charge_cooldown = 5,
    discharge_cooldown = 5,
    picture = {
      layers = {
        {
          filename = "__Lightning__/graphics/entity/mighty.png",
          width = 256,
          height = 512,
          scale = 0.8,
          shift = {0, -3},
          hr_version = {
            filename = "__Lightning__/graphics/entity/mighty-hr.png",
            width = 512,
            height = 1024,
            scale = 0.4,
            shift = {0, -3},
          },
        },
        {
          filename = "__Lightning__/graphics/entity/mighty-shadow.png",
          width = 512,
          height = 256,
          scale = 0.8,
          shift = {4, 0},
          draw_as_shadow = true,
          hr_version = {
            filename = "__Lightning__/graphics/entity/mighty-shadow-hr.png",
            width = 1024,
            height = 512,
            scale = 0.4,
            shift = {4, 0},
            draw_as_shadow = true,
          },
        },
      }
    },
    -- discharge_animation = {},
    -- recharging_animation = {},
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_sound = {
      sound = {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound = {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 1
      },
      max_sounds_per_type = 2,
      audible_distance_modifier = 0.5,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    recharging_light = {intensity = 0.6, size = 5},
    radius_visualisation_specification = {
      distance = math.floor(shared.max_catch_radius*1.5),
      sprite = {
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
        height = 10,
        width = 10
      }
    },
  },
})

table.insert(
  data.raw.technology["electric-energy-accumulators"].effects,
  { type = "unlock-recipe", recipe = name }
)
