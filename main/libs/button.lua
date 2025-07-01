local added_buttons = {}
local trigger_action = hash("click")


button = {}


function button.reset()
	added_buttons = {}
end



function button.add(node_id, button_name, button_function, function_params)
	added_buttons[button_name] = {["function"] = button_function, ["node"] = gui.get_node(node_id), ["params"] = function_params}
end



function button.set_trigger_action(action_id)
	trigger_action = hash(action_id)
end



function button.set_enabled(button_name, is_enabled)
	gui.set_enabled(added_buttons[button_name]["node"], is_enabled)
end



function button.set_enabled_all(button_name, is_enabled)
	for name, button in pairs(added_buttons) do
		gui.set_enabled(button["node"], is_enabled)
	end
end



function button.on_input(action_id, action)
	if action_id == trigger_action then
		if action.pressed then
			for name, button in pairs(added_buttons) do	
				if gui.is_enabled(button["node"]) then
					if gui.pick_node(button["node"], action.x, action.y) then
						button["function"](button["params"])
					end
				end
			end
		end
	end
end