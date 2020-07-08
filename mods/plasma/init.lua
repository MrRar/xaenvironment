plasma = {}
minetest.register_node("plasma:plasma_cannon",{
	stack_max= 1,
	description = "Plasma cannon",
	drawtype = "mesh",
	mesh = "plasma_cannon.obj",
	tiles = {"plasma_cannon_colors.png"},
	groups = {dig_immediate=3},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	on_use=function(itemstack, user, pointed_thing)
		local dir = user:get_look_dir()
		local p = user:get_pos()
		local e = minetest.add_entity({x=p.x+(dir.x*2),y=p.y+1+(dir.y*2),z=p.z+(dir.z*2)},"plasma:orb")
		local en = e:get_luaentity()
		en.charging = true
		en.user = user
		en.user_name = user:get_player_name()
	end,
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" and default.defpos(pointed_thing.above,"buildable_to") and not minetest.is_protected(user:get_player_name(),pointed_thing.above) then
			minetest.item_place_node(ItemStack("plasma:plasma_cannon_placeable"), user, pointed_thing)
		end
	end
})

minetest.register_node("plasma:plasma_cannon_placeable",{
	stack_max= 1,
	description = "Plasma cannon",
	drop = "plasma:plasma_cannon",
	drawtype = "mesh",
	mesh = "plasma_cannon_placeable.obj",
	tiles = {"plasma_cannon_colors.png"},
	groups = {dig_immediate=3,not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	visual_scale = 0.4,
	selection_box = {
		type = "fixed",
		fixed = {-0.7, -0.3, -0.2, 0.7, 0.2, 0.2}
	}
})



--[[


			minetest.add_particlespawner({
				amount = 5,
				time =0.2,
				minpos = {x=pos.x-0.5, y=pos.y, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y, z=pos.z+0.5},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=math.random(3,6), z=0},
				minacc = {x=0, y=2, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 1,
				maxexptime = 3,
				minsize = 5,
				maxsize = 10,
				texture = "default_item_smoke.png",
				collisiondetection = true,
			})



			local item = clicker:get_wielded_item():to_table()
				item.name = "quads:petrol_tank_empty"
				clicker:set_wielded_item(item)



--]]



minetest.register_entity("plasma:orb",{
	hp_max = 1,
	physical = false,
	pointable=false,
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
	visual="sprite",
	textures={"plasma_orb1.png"},
	visual_size = {x=1,y=1},
	--makes_footstep_sound = true,
	charging = false,
	charging_time = 0,
	img = 1,
	timer = 0,
	start_timeout = 0,
	get_staticdata = function(self)
		return minetest.serialize({power=self.power,user=self.user,user_name=self.user_name})
	end,
	anim=function(self)
		self.img = self.img +1
		if self.img > 8 then
			self.img = 1
		end
		self.object:set_properties({textures={"plasma_orb"..self.img..".png"}})
	end,
	on_activate=function(self, staticdata)
		local s = minetest.deserialize(staticdata) or {}
		self.plasmaorb = math.random(1,9999)
		self.power = s.power or 1
		self.user = s.user
		self.user_name = s.user_name

		self.object:set_properties({visual_size = {x=1+self.power*0.01,y=1+self.power*0.01,z=1+self.power*0.01}})
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)

			--	local inv = puncher:get_inventory()
			--	if inv:room_for_item("main","quads:quad") then
			--		inv:add_item("main","quads:quad")
			--		self.object:remove()
			--	end
			--end

	end,
	explode=function(self,juststop)
		if self.ex then
			return
		end
		self.ex = true
		if self.sound1 then
			minetest.sound_stop(self.sound1)
		end
		if self.sound2 then
			minetest.sound_stop(self.sound2)
		end
		if self.sound3 then
			minetest.sound_stop(self.sound3)
		end
		if juststop then
			return
		end

		local pos = self.object:get_pos()

		if self.power > 50 then
			minetest.sound_play("plasma_explosion", {pos=pos, gain = 9,max_hear_distance = 100})
		else
			minetest.sound_play("plasma_boom", {pos=pos, gain = 4,max_hear_distance = 50})
		end

		self.power = self.power > 8 and self.power or 8

		if self.user and self.user_name then
			if self.power >= 100 then
				exaachievements.customize(self.user,"100% Clean")
			end
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.power/2)) do
				local en = ob:get_luaentity()
				local p = ob:get_pos()
				if p and not (ob:is_player() and ob:get_player_name() == self.user_name) and not (en and (en.plasmaorb == self.plasmaorb or en.name == "__builtin:item" )) then
					local d = self.power-vector.distance(pos,p)
					if d > 90 then
						d = 1000
					end
					default.punch(ob,self.user,d)
					self.obs(ob)
				end
			end
		else
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.power/2)) do
				local en = ob:get_luaentity()
				local p = ob:get_pos()
				if p and not (en and en.plasmaorb == self.plasmaorb) then
					local d = self.power-vector.distance(pos,p)
					if d > 90 then
						d = 1000
					end
					default.punch(ob,ob,self.power-vector.distance(pos,p))
					self.obs(ob)
				end
			end
		end
		local o = minetest.add_entity(pos,"plasma:impulse")
		local en = o:get_luaentity()
		en.end_scale = self.power
		self.object:remove()
	end,
	obs=function(ob)
		if ob and ob:get_pos() then
			local en = ob:get_luaentity()
			if en and en.examob and (en.hp <= 0 or en.dying or en.dead) then
				examobs.dying(en,2)
				local t = "default_cloud.png^[colorize:#000"
				ob:set_properties({textures={t,t,t,t,t,t}})
				en.on_abs_step =  function(self)
					examobs.anim(self,"stand")
				end
				
			end
		end
	end,
	on_step=function(self,dtime)
		local pos = self.object:get_pos()

		if not pos then
			self:explode(ob,true)
			return
		end
		self.timer = self.timer + dtime
		if self.timer > 0.1 then
			self.timer = 0
			self:anim()
		end
		if self.start_timeout < 0.01 then
			self.start_timeout = self.start_timeout + dtime
			return
		end
		if self.user and self.charging then
			self.start_timeout = 0
			local key = self.user:get_player_control()
			if key.LMB then

				local dir = self.user:get_look_dir()
				local p = self.user:get_pos()
				local d = 1
				local npos = {x=p.x+(dir.x*d), y=p.y+(dir.y*d)+1.6, z=p.z+(dir.z*d)}
				local v = {x = (npos.x - pos.x)*20, y = (npos.y - pos.y)*20, z = (npos.z - pos.z)*20}
				self.object:set_velocity(v)
				self.power = self.power + dtime*40
				self.charging_time = self.charging_time + dtime

				if not self.sound1 then
					self.sound1 = minetest.sound_play("plasma_charge_orb", {object=self.object, gain = 4,max_hear_distance = 10})
				end

				if self.power > 100 then
					self.power = 100
				else
					self.object:set_properties({visual_size = {x=1+self.power*0.01,y=1+self.power*0.01,z=1+self.power*0.01}})
				end

				if self.charging_time >= 2.2 then
					if not self.sound2 then
						self.power = 100
						self.sound2 = minetest.sound_play("plasma_core_loaded", {object=self.object, gain = 4,max_hear_distance = 10,loop=true})
					end
				end
				return
			else
				if self.sound1 then
					minetest.sound_stop(self.sound1)
				end
				if self.sound2 then
					minetest.sound_stop(self.sound2)
				end
				if not self.sound3 then
					self.sound3 = minetest.sound_play("plasma_orb", {object=self.object, gain = 4,max_hear_distance = 10,loop=true})
					minetest.sound_play("plasma_shoot", {object=self.object, gain = 4,max_hear_distance = 10})
					local dir = self.user:get_look_dir()
					local v = self.object:set_velocity({x=dir.x*20,y=dir.y*20,z=dir.z*20})
					self.start_timeout = 1
					self.charging = nil
				end
			end
		end

		if default.defpos(pos,"walkable") then
			self:explode(ob)
			return
		end

		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1+self.power*0.03)) do
			local en = ob:get_luaentity()
			if not (ob:is_player() and ob:get_player_name() == self.user_name) and not (en and en.plasmaorb == self.plasmaorb) then
				self:explode()
				return
			end
		end
	end
})




minetest.register_entity("plasma:impulse",{
	hp_max = 1000,
	physical = false,
	pointable=false,
	visual="mesh",
	mesh = "plasma_impulse.obj",
	textures={"default_cloud.png^[colorize:#fc03e3"},
	visual_size = {x=1,y=1},
	timer = 0,
	on_activate=function(self, staticdata)
		self.scale = 1
		self.end_scale = 1
	end,
	on_step=function(self,dtime)
		self.timer = self.timer + dtime
		if not self.timeout then
			if self.timer < 0.01 then
				return
			else
				self.timeout = true
				self.timer = 0
			end
		end
		if self.scale < self.end_scale then
			self.scale = self.scale + dtime * (self.end_scale*5)
			self.object:set_properties({visual_size = {x=self.scale,y=self.scale,z=self.scale}})
		else
			self.object:remove()
		end
	end
})
--[[
minetest.register_craft({
	output="plasma:plasma_cannon",
	recipe={
		{"m2aterials:plant_extracts_gas","default:carbon_lump","quads:petrol_tank_empty"},
		{"player_style:bottle","quads:bottle_with_oil",""},
	},
	replacements={
		{"player_style:bottle","materials:glass_bottle"},
		{"quads:bottle_with_oil","materials:glass_bottle"}
	}
})
--]]