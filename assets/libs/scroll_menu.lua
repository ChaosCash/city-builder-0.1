local action_name_scroll_up = hash("scroll_up")
local action_name_scroll_down = hash("scroll_down")
local action_name_click = hash("click")
local added_scroll_menus = {}
local active_scroll_menu = nil



scroll_menu = {}



function scroll_menu.update_content(scroll_menu_name, content)
	local cur_scroll_menu = added_scroll_menus[scroll_menu_name]
	cur_scroll_menu["content"] = content

	if table.maxn(content) < cur_scroll_menu["cur_pos"] + cur_scroll_menu["node_count"] then
		cur_scroll_menu["cur_pos"] = math.max(table.maxn(content) - cur_scroll_menu["node_count"], 0)
	end

	update_scroll_menu_text(cur_scroll_menu)
end



function update_scroll_menu_text(scroll_menu)
	for k1, node in pairs(scroll_menu["nodes"]) do
		if type(node) == "table" then
			for k2, sub_node in pairs(node) do
				if scroll_menu["content"][k1 + scroll_menu["cur_pos"]] then
					gui.set_text(sub_node, scroll_menu["content"][k1 + scroll_menu["cur_pos"]][k2])
				end
			end
		else
			gui.set_text(node, scroll_menu["content"][k1 + scroll_menu["cur_pos"]])
		end
	end
end



function scroll_menu.add(node_id, scroll_menu_name, click_function)
	local cur_scroll_menu = {content = {},["nodes"] = {}, ["main_node"] = gui.get_node(node_id), ["node_count"] = 0, ["cur_pos"] = 0, click_function = click_function}

	for k,node in pairs(gui.get_tree(gui.get_node(node_id))) do
		local node_name = tostring(k)
		if string.find(node_name, "text field") then
			local text_field_number = tonumber(node_name:match('text field (%d*)'))
			local key = node_name:match('%["(.*)"%]')
			if key then
				if not cur_scroll_menu["nodes"][text_field_number] then
					cur_scroll_menu["node_count"] = cur_scroll_menu["node_count"] + 1
					cur_scroll_menu["nodes"][text_field_number] = {}
				end
				cur_scroll_menu["nodes"][text_field_number][key] = node
			else
				cur_scroll_menu["node_count"] = cur_scroll_menu["node_count"] + 1
				cur_scroll_menu["nodes"][text_field_number] = node
			end

		end
	end

	added_scroll_menus[scroll_menu_name] = cur_scroll_menu
end



function scroll_menu.reset()
	added_scroll_menus = {}
	active_scroll_menu = nil
end



function scroll_menu.set_action_name_click(name)
	action_name_click = hash(name)
end



function scroll_menu.set_action_name_scroll_up(name)
	action_name_scroll_up = hash(name)
end



function scroll_menu.set_action_name_scroll_down(name)
	action_name_scroll_down = hash(name)
end



function scroll_menu.on_input(action_id, action)
	if action_id == action_name_scroll_down and not action.pressed then
		for name, cur_scroll_menu in pairs(added_scroll_menus) do
			if table.maxn(cur_scroll_menu["content"]) - cur_scroll_menu["node_count"] > cur_scroll_menu["cur_pos"] then
				cur_scroll_menu["cur_pos"] = cur_scroll_menu["cur_pos"] + 1
				update_scroll_menu_text(cur_scroll_menu)
			end
		end
		return
	end


	if action_id == action_name_scroll_up and not action.pressed then
		for name, cur_scroll_menu in pairs(added_scroll_menus) do
			if cur_scroll_menu["cur_pos"] > 0 then
				cur_scroll_menu["cur_pos"] = cur_scroll_menu["cur_pos"] - 1
				update_scroll_menu_text(cur_scroll_menu)
			end
		end
		return
	end


	if action_id == action_name_click and action.pressed then
		for name, cur_scroll_menu in pairs(added_scroll_menus) do
			if cur_scroll_menu["click_function"] then
				for k1, node in pairs(cur_scroll_menu["nodes"]) do
					if type(node) == "table" then
						for k2, sub_node in pairs(node) do
							if gui.pick_node(sub_node, action.x, action.y) then
								cur_scroll_menu["click_function"](name, cur_scroll_menu["content"][k1 + cur_scroll_menu["cur_pos"]],k1 , k2)
							end
						end
					else
						if gui.pick_node(node, action.x, action.y) then
							cur_scroll_menu["click_function"](name, cur_scroll_menu["content"][k1 + cur_scroll_menu["cur_pos"]], k1)
						end
					end
				end
			end
		end
		return
	end



end