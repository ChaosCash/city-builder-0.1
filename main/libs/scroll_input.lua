local action_name_scroll_up = hash("scroll_up")
local action_name_scroll_down = hash("scroll_down")
local added_inputs = {}
local active_input = nil



scroll_input = {}



function scroll_input.get_value(scroll_input_name)
	return added_inputs[scroll_input_name]["cur_value"]
end



function scroll_input.reset()
	added_inputs = {}
end



function scroll_input.set_action_name_scroll_up(name)
	action_name_scroll_up = hash(name)
end



function scroll_input.set_action_name_scroll_down(name)
	action_name_scroll_down = hash(name)
end



function scroll_input.add(node_id,input_name,min,max)
	added_inputs[input_name] = {["node"] = gui.get_node(node_id), ["max"] = max or -1, ["min"] = min or -1, ["cur_value"] = tonumber(gui.get_text(gui.get_node(node_id))) or 0}
end



function scroll_input.on_input(action_id, action)
	if not action_id then
		for name, input in pairs(added_inputs) do
			if gui.pick_node(input["node"], action.x, action.y) then
				active_input = input
				return
			end
		end
		active_input = nil
	end

	
	if active_input then
		if action_id == action_name_scroll_up and not action.pressed then
			if active_input["cur_value"] + 1 <= active_input["max"] or active_input["max"] == -1 then
				active_input["cur_value"] = active_input["cur_value"] + 1
				gui.set_text(active_input["node"], active_input["cur_value"])
				return
			end
		end

		if action_id == action_name_scroll_down and not action.pressed then
			if active_input["cur_value"] - 1 >= active_input["min"] or active_input["min"] == -1 then
				active_input["cur_value"] = active_input["cur_value"] - 1
				gui.set_text(active_input["node"], active_input["cur_value"])
				return
			end
		end
	end

end