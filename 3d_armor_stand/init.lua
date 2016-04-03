local armor_stand_formspec = "size[8,7.5]" ..
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"list[current_name;armor;3,0;2,3;]" ..
	"list[current_player;main;0,3.5;8,1;]" ..
	"list[current_player;main;0,4.75;8,3;8]" ..
	"listring[current_name;armor]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0,3.5)

local function update_entity(pos)
	local object = nil
	local node = minetest.get_node(pos)
	local objects = minetest.get_objects_inside_radius(pos, 1) or {}
	for _, obj in pairs(objects) do
		local ent = obj:get_luaentity()
		if ent then
			if ent.name == "3d_armor_stand:armor_entity" then
				-- Remove duplicates
				if object then
					obj:remove()
				else
					object = obj
				end
			end
		end
	end
	if object then
		if node.name ~= "3d_armor_stand:armor_stand" then
			object:remove()
			return
		end
	else
		object = minetest.add_entity(pos, "3d_armor_stand:armor_entity")
	end
	if object then
		local texture = "3d_armor_trans.png"
		local textures = {}
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local yaw = 0
		if inv then
			for i=1, 6 do
				local stack = inv:get_stack("armor", i)
				if stack:get_count() == 1 then
					local item = stack:get_name()
					local def = stack:get_definition()
					local texture = def.texture or item:gsub("%:", "_")
					table.insert(textures, texture..".png")
				end
			end
		end
		if #textures > 0 then
			texture = table.concat(textures, "^")
		end
		if node.param2 then
			local rot = node.param2 % 4
			if rot == 1 then
				yaw = 3 * math.pi / 2
			elseif rot == 2 then
				yaw = math.pi
			elseif rot == 3 then
				yaw = math.pi / 2
			end
		end
		object:setyaw(yaw)
		object:set_properties({textures={texture}})
	end
end

minetest.register_node("3d_armor_stand:armor_stand", {
	description = "Armor stand",
	drawtype = "mesh",
	mesh = "3d_armor_stand.obj",
	tiles = {"default_wood.png", "default_steel_block.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5, 0.5,1.5,0.5}
	},
	groups = {choppy=2, oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", armor_stand_formspec)
		meta:set_string("infotext", "Armor Stand")
		local inv = meta:get_inventory()
		inv:set_size("armor", 6)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("armor")
	end,
	after_place_node = function(pos)
		minetest.add_entity(pos, "3d_armor_stand:armor_entity")
	end,
	on_metadata_inventory_move = function(pos)
		update_entity(pos)
	end,
    on_metadata_inventory_put = function(pos)
		update_entity(pos)
	end,
    on_metadata_inventory_take = function(pos)
		update_entity(pos)
	end,
	after_destruct = function(pos)
		update_entity(pos)
	end,
})

minetest.register_entity("3d_armor_stand:armor_entity", {
	physical = true,
	visual = "mesh",
	mesh = "3d_armor_entity.obj",
	visual_size = {x=1, y=1},
	collisionbox = {-0.3,-0.3,-0.3, 0.3,1.5,0.3},
	textures = {"3d_armor_trans.png"},
	on_activate = function(self)
		local pos = self.object:getpos()
		update_entity(pos)
	end,
})

minetest.register_craft({
	output = "3d_armor_stand:armor_stand",
	recipe = {
		{"", "default:fence_wood", ""},
		{"", "default:fence_wood", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
})

