minetest.register_node("examobs:hat", {
	tiles = {"default_coalblock.png^[colorize:#333333aa"},
	groups = {dig_immediate = 3,not_in_creative_inventory=1},
	use_texture_alpha = "opaque",
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(1,10))
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_node({x=pos.x, y=pos.y-1 , z=pos.z}).name=="default:snowblock" then
			minetest.add_entity({x=pos.x, y=pos.y-1 , z=pos.z}, "examobs:snowman")
			minetest.remove_node({x=pos.x, y=pos.y-1 , z=pos.z})
			minetest.remove_node(pos)
		end
		return false
	end,
	drawtype="nodebox",
	node_box ={
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.22, -0.4375, -0.22, 0.22, 0.0625, 0.22}
		}
	}
})

minetest.register_entity("examobs:hat",{
	hp_max = 20,
	physical =true,
	pointable=false,
	visual = "wielditem",
	textures ={"examobs:hat"},
	visual_size={x=2,y=2},
	on_step=function(self, dtime)
		self.t=self.t+dtime
		if self.t<1 then return end
		self.t=0
		if not self.object:get_attach() then
			self.object:remove()
		end
	end,
	t=0,
})

minetest.register_node("examobs:snowman", {
	tiles = {"default_snow.png"},
	groups = {cracky = 2,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box ={
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.375, 0.5, -0.375, 0.375, 1.2, 0.375},
			{-0.25, 1.2, -0.25, 0.25, 1.6, 0.25}
		}
	}
})

bows.register_arrow("snowball",{
	description="Snowball arrow",
	inventory_image="default_snowball.png",
	damage=1,
	craft_count=1,
	groups={treasure=1},
	on_hit_node=function(self,pos,user,lastpos)
		lastpos = lastpos or pos
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = lastpos,
			maxpos = lastpos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "default_snowball.png",
			collisiondetection = true,
		})
		bows.arrow_remove(self)
		return self
	end,
	on_hit_object=function(self,target,hp,user,lastpos)
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = lastpos,
			maxpos = lastpos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "default_snowball.png",
			collisiondetection = true,
		})
		bows.arrow_remove(self)
	end,
	craft={
		{"default:snow","default:snow"},
	}
})

examobs.register_mob({
	description="A monster consisting of snow without face, also spitting snow",
	name="snowman",
	aggressivity = 2,
	walk_speed = 1,
	team="snow",
	textures={"default_snow.png"},
	swiming = 0,
	type="monster",
	hp=10,
	range=2,
	collisionbox={-0.5,-0.45,-0.5,0.5,2.0,0.5},
	visual="cube",
	lay_on_death = 0,
	inv={["default:snow"]=1,["default:snowblock"]=3,["examobs:hat"]=1},
	spawn_on={"group:snowy","default:dirt_with_snow"},
	on_spawn=function(self)
		self.object:set_properties({visual="wielditem",visual_size={x=0.6,y=0.6},textures={"examobs:snowman"}})
		local e=minetest.add_entity(self.object:get_pos(), "examobs:hat")
		e:set_attach(self.object, "",{x=0, y=62 , z=0}, {x=0, y=0, z=0})
		self.hat=e
	end,
	on_walk=function(self,x,y,z)
		examobs.jump(self)
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	on_load=function(self)
		self.on_spawn(self)
	end,
	snowbtime = 0,
	step=function(self)
		if self.fight then
			if self.snowbtime <= 0 then
				self.snowbtime = 5
				if examobs.viewfield(self,self.fight) and examobs.visiable(self.object,self.fight:get_pos()) then
					local pos2 = self.fight:get_pos()
					if pos2 and pos2.x then
						examobs.shoot_arrow(self,pos2,"examobs:arrow_snowball")
					end
				end
			else
				self.snowbtime=self.snowbtime -1
			end
		end
	end,
	death=function(self,puncher,pos)
		if self.hat and self.hat:get_attach() then
			self.hat:set_detach()
			self.hat:remove()
		end
		minetest.add_particlespawner({
			amount = 30,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 2,
			maxsize = 4,
			texture = "default_snowball.png",
			collisiondetection = true,
		})
		minetest.sound_play("default_snow_footstep", {pos=pos, gain = 1.0, max_hear_distance = 5,})
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "default_snow.png",
			collisiondetection = true,
		})
	end
})

examobs.register_mob({
	description="A monster consisting of snow, also spitting snow",
	name="snowman_like",
	aggressivity = 2,
	team="snow",
	textures = {"player_style_snowman.png"},
	swiming = 0,
	type="monter",
	hp=10,
	lay_on_death = 0,
	inv={["default:snow"]=1,["default:snowblock"]=3,["examobs:hat"]=1},
	spawn_on={"group:snowy","default:dirt_with_snow"},
	animation = {
		stand={x=1,y=39,speed=30,loop=false},
		walk={x=41,y=61,speed=30,loop=false},
		run={x=80,y=99,speed=60},
		lay={x=113,y=123,speed=0,loop=false},
		attack={x=80,y=99,speed=60},
	},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	snowbtime = 0,
	step=function(self)
		if self.fight then
			if self.snowbtime <= 0 then
				self.snowbtime = 5
				if examobs.viewfield(self,self.fight) and examobs.visiable(self.object,self.fight:get_pos()) then
					local pos2 = self.fight:get_pos()
					if pos2 and pos2.x then
						examobs.shoot_arrow(self,pos2,"examobs:arrow_snowball")
					end
				end
			else
				self.snowbtime=self.snowbtime -1
			end
		end
	end,
	death=function(self,puncher,pos)
		if self.hat and self.hat:get_attach() then
			self.hat:set_detach()
			self.hat:remove()
		end
		minetest.add_particlespawner({
			amount = 30,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 2,
			maxsize = 4,
			texture = "default_snowball.png",
			collisiondetection = true,
		})
		minetest.sound_play("default_snow_footstep", {pos=pos, gain = 1.0, max_hear_distance = 5,})
	end,
	on_punched=function(self,puncher)
		local pos=self.object:get_pos()
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "default_snow.png",
			collisiondetection = true,
		})
	end
})