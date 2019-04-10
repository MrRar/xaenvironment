minetest.register_node("default:ladder", {
	description = "Ladder",
	drop="default:stick",
	tiles={"default_wood.png"},
	groups = {ladder=1,choppy=3,oddly_breakable_by_hand=3,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.35, 0.4375, -0.4375, -0.25},
			{-0.4375, -0.5, -0.05, 0.4375, -0.4375, 0.05},
			{-0.4375, -0.5, 0.25, 0.4375, -0.4375, 0.35},
			{-0.5, -0.5, -0.5, -0.4375, -0.375, 0.5},
			{0.4375, -0.5, -0.5, 0.5, -0.375, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}}
	},
	climbable = true,
	paramtype = "light",
	paramtype2 = "wallmounted",
	legacy_wallmounted=true,
	walkable=false,
})

minetest.register_node("default:stick_on_ground", {
	description = "Stick",
	drop="default:stick",
	tiles={"default_tree.png"},
	groups = {stick=1,dig_immediate=3,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.05,-0.5,-0.5,0.05,-0.45,0.5}},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable=false,
	on_construct = function(pos)
		minetest.swap_node(pos,{name="default:stick_on_ground",param2=math.random(0,3)})
	end
})

minetest.register_node("default:torch", {
	description = "Torch",
	tiles={"default_torch.png"},
	wield_scale = {x=2,y=2,z=2},
	groups = {dig_immediate=3,flammable=3,igniter=1},
	drawtype = "mesh",
	mesh="default_torch.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagetes = true,
	on_place=function(itemstack, placer, pointed_thing)
		if minetest.get_item_group(minetest.get_node(pointed_thing.under).name,"attached_node")>0 then
			return itemstack
		end
		local fdw=minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))
		if fdw == 1 then
			minetest.set_node(pointed_thing.above,{name="default:torch_floor",param2=fdw})
		else
			minetest.set_node(pointed_thing.above,{name="default:torch_lean",param2=fdw})
		end
		local meta = minetest.get_meta(pointed_thing.above)
		meta:set_int("date",default.date("get"))
		meta:set_int("hours",math.random(24,72))
		minetest.get_node_timer(pointed_thing.above):start(10)
		itemstack:take_item()
		return itemstack
	end,
})


minetest.register_node("default:torch_floor", {
	description = "Torch",
	drop = "default:torch",
	tiles={"default_torch.png"},
	groups = {dig_immediate=3,flammable=3,igniter=1,attached_node=1,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	floodable = true,
	drawtype = "mesh",
	mesh="default_torch.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagetes = true,
	walkable = false,
	light_source = 10,
	damage_per_second = 2,
	selection_box = {type = "fixed",fixed={-0.1, -0.5, -0.1, 0.1, 0.2, 0.1}},
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("h",meta:get_int("date")) > meta:get_int("hours") then
			minetest.remove_node(pos)
			return false
		end
		return true
	end
})

minetest.register_node("default:torch_lean", {
	description = "Torch",
	drop = "default:torch",
	tiles={"default_torch.png"},
	groups = {dig_immediate=3,flammable=3,igniter=1,not_in_creative_inventory=1,attached_node=1},
	sounds = default.node_sound_wood_defaults(),
	drawtype = "mesh",
	floodable = true,
	mesh="default_torch_lean.obj",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagetes = true,
	walkable = false,
	light_source = 10,
	damage_per_second = 2,
	selection_box = {type = "fixed",fixed={-0.1, -0.5, -0.3, 0.1, 0, 0.3}},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_int("date",default.date("get"))
		meta:set_int("hours",math.random(24,72))
		minetest.get_node_timer(pos):start(10)
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("h",meta:get_int("date")) > meta:get_int("hours") then
			minetest.remove_node(pos)
			return false
		end
		return true
	end
})

minetest.register_node("default:glass", {
	description = "Glass",
	tiles={"default_glass_with_frame.png","default_glass.png"},
	groups = {glass=1,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "glasslike_framed_optional",
	paramtype = "light",
	paramtype2 = "glasslikeliquidelevel",
})

minetest.register_node("default:dirt_with_grass", {
	description = "Dirt with grass",
	drop="default:dirt",
	tiles={"default_grass.png","default_dirt.png","default_dirt.png^default_grass_side.png"},
	groups = {dirt=1,soil=1,crumbly=3,spreading_dirt_type=1,},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt", {
	description = "Dirt",
	tiles={"default_dirt.png"},
	groups = {dirt=1,soil=1,crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

--||||||||||||||||
-- ======================= Stone
--||||||||||||||||

minetest.register_node("default:stone", {
	description = "Stone",
	drop = "default:cobble",
	tiles={"default_stone.png"},
	groups = {stone=1,cracky=3},
	sounds = default.node_sound_stone_defaults(),

})
minetest.register_node("default:cobble", {
	description = "Cobble",
	tiles={"default_cobble.png"},
	groups = {stone=1,cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:gravel", {
	description = "Gravel",
	tiles={"default_gravel.png"},
	groups = {crumbly=2,falling_node=1},
	sounds = default.node_sound_gravel_defaults(),
	drowning = 1,
	drop ={
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 8},
			{items = {"default:gravel"}}
		}
	}
})

minetest.register_node("default:sandstone", {
	description = "Sand stone",
	tiles={"default_sandstone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:sand", {
	description = "Sand",
	tiles={"default_sand.png"},
	groups = {crumbly=3,sand=1,falling_node=1},
	sounds = default.node_sound_dirt_defaults(),
	drowning = 1,
	drop ={
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 8},
			{items = {"default:sand"}}
		}
	}
})

--||||||||||||||||
-- ======================= Water
--||||||||||||||||

minetest.register_node("default:ice", {
	description = "Ice",
	tiles={"default_ice.png"},
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("default:water_source", {
	description = "Water source (fresh water)",
	tiles={
		{
			name = "default_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {water=1, liquid=1, cools_lava=1},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 110, r = 42, g = 128, b = 231},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("default:water_flowing", {
	description = "Water flowing",
	special_tiles={
		{
			name = "default_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {water=1, liquid=1, cools_lava=1,not_in_creative_inventory=1},
	drawtype = "flowingliquid",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 110, r = 42, g = 128, b = 231},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("default:salt_water_source", {
	description = "Salt water source",
	tiles={
		{
			name = "default_salt_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_salt_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {saltwater=1, liquid=1, cools_lava=1},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:salt_water_flowing",
	liquid_alternative_source = "default:salt_water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 100, r = 0, g = 90, b = 133},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("default:salt_water_flowing", {
	description = "Salt water flowing",
	special_tiles={
		{
			name = "default_salt_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_salt_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {saltwater=1, liquid=1, cools_lava=1,not_in_creative_inventory=1},
	drawtype = "flowingliquid",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:salt_water_flowing",
	liquid_alternative_source = "default:salt_water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 100, r = 0, g = 90, b = 133},
	sounds = default.node_sound_water_defaults(),
})

--||||||||||||||||
-- ======================= Lava
--||||||||||||||||

minetest.register_node("default:lava_source", {
	description = "Lava source",
	tiles={
		{
			name = "default_lava_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		},
		{
			name = "default_lava_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		}
	},
	groups = {lava=1, liquid=1,igniter=3},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	light_source=13,
	buildable_to = true,
	drop = "",
	drowning = 1,
	damage_per_second = 9,
	liquidtype = "source",
	liquid_alternative_flowing = "default:lava_flowing",
	liquid_alternative_source = "default:lava_source",
	liquid_viscosity = 20,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0},
})

minetest.register_node("default:lava_flowing", {
	description = "Lava flowing",
	special_tiles={
		{
			name = "default_lava_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		},
		{
			name = "default_lava_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		}
	},
	groups = {lava=1, liquid=1,not_in_creative_inventory=1,igniter=3},
	drawtype = "flowingliquid",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source=13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	damage_per_second = 9,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:lava_flowing",
	liquid_alternative_source = "default:lava_source",
	liquid_viscosity = 20,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0},
})



--||||||||||||||||
-- ======================= Metal
--||||||||||||||||

minetest.register_node("default:ironblock", {
	description = "Ironblock",
	tiles={"default_ironblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:goldblock", {
	description = "Goldblock",
	tiles={"default_goldblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:uraniumactiveblock", {
	description = "Active uraniumblock",
	tiles={"default_uraniumactiveblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:silverblock", {
	description = "Silverblock",
	tiles={"default_silverblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:uraniumblock", {
	description = "Uraniumblock",
	tiles={"default_uraniumblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:copperblock", {
	description = "Copperblock",
	tiles={"default_copperblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:steelblock", {
	description = "Steelblock",
	tiles={"default_steelblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:tinblock", {
	description = "Tinblock",
	tiles={"default_tinblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:bronzeblock", {
	description = "Bronzeblock",
	tiles={"default_bronzeblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})