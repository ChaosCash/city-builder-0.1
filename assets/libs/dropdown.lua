local action_name_click = hash("click")
local added_dropdowns = {}



dropdown = {}


function dropdown.get_selected_option(dropdown_name)
	return gui.get_text(added_dropdowns[dropdown_name]["options"][1])
end



function dropdown.set_action_name_click(name)
	action_name_click = hash(name)
end



function dropdown.reset()
	added_dropdowns = {}
end



function dropdown.add(node_id, dropdown_name, is_open)
	local cur_dropdown_tree = gui.get_tree(gui.get_node(node_id))
	local cur_dropdown = {["options"] = {}, ["is_open"] = is_open or false}
	
	for k,v in pairs(cur_dropdown_tree) do
		local node_name = tostring(k)
		
		if string.find(node_name, "arrow down") then
			cur_dropdown["arrow_down"] = v
		elseif string.find(node_name, "arrow up") then
			cur_dropdown["arrow_up"] = v
		elseif string.find(node_name, "option") then
			local option_start, option_end = string.find(node_name,"option %d*")
			local option = tonumber(string.sub(node_name, option_start + 6, option_end))
			cur_dropdown["options"][option] = v
		end
	end
	
	added_dropdowns[dropdown_name] = cur_dropdown
end



function dropdown.on_input(action_id, action)
	if action_id == action_name_click then
		if action.pressed then
		
			for name, dropdown in pairs(added_dropdowns) do
				if dropdown["is_open"] then
					for option, option_node in pairs(dropdown["options"]) do
						if gui.pick_node(option_node, action.x, action.y) then
							local option_text = gui.get_text(option_node)
							gui.set_text(option_node, gui.get_text(dropdown["options"][1]))
							gui.set_text(dropdown["options"][1], option_text)
							
							dropdown["is_open"] = false
							gui.set_enabled(dropdown["arrow_up"], false)
							gui.set_enabled(dropdown["arrow_down"], true)
							
							for option, option_node in pairs(dropdown["options"]) do
								if option ~= 1 then
									gui.set_enabled(option_node, false)
								end
							end
							return
						end
					end
				end
			end
			
			
			for name, dropdown in pairs(added_dropdowns) do
				if gui.pick_node(dropdown["options"][1], action.x, action.y) then
					dropdown["is_open"] = not dropdown["is_open"]
					for option, option_node in pairs(dropdown["options"]) do
						if option ~= 1 then
							gui.set_enabled(option_node, dropdown["is_open"])
						end
					end
					gui.set_enabled(dropdown["arrow_up"], dropdown["is_open"])
					gui.set_enabled(dropdown["arrow_down"], not dropdown["is_open"])
					return
				end
			end
			
		end
	end
end