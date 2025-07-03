local backspace_count = 0
local backspace_interval = 4
local backspace_delay = 24
local action_name_click = hash("click")
local action_name_text = hash("text")
local action_name_backspace = hash("backspace")
local action_name_tab = hash("tab")
local action_name_enter = hash("enter")
local cursor_interval = 0.5


input_box = {}
local added_boxes = {}
local fucused_box = nil
local cursor = nil
local cursor_timer = nil
local cursor_is_visible = false
local cursor_is_enabled = true



function input_box.reset()
	added_boxes = {}
	cursor = nil
end



function input_box.get_text(input_box_name)
	return gui.get_text(added_boxes[input_box_name]["node"])
end



function input_box.set_enabled_all(enabled)
	for name, box in pairs(added_boxes) do
		gui.set_enabled(box["node"], enabled)
	end

	if cursor then
		gui.set_enabled(cursor, enabled)
	end
end



function input_box.set_enabled_box(box_name, enabled)
	gui.set_enabled(added_boxes[box_name]["node"], enabled)
end



function input_box.set_enabled_cursor(enabled)
	gui.set_enabled(cursor, enabled)
end



function input_box.set_enter_box(input_box_name, enter_input_box_name)
	added_boxes[input_box_name]["enter_box"] = added_boxes[enter_input_box_name]
end



function input_box.set_enter_function(input_box_name, enter_function, params)
	added_boxes[input_box_name]["enter_function"] = enter_function
	added_boxes[input_box_name]["enter_function_params"] = params
end



function input_box.set_tab_box(input_box_name, tab_input_box_name)
	added_boxes[input_box_name]["tab_box"] = added_boxes[tab_input_box_name]
end



function input_box.set_tab_function(input_box_name, tab_function, params)
	added_boxes[input_box_name]["tab_function"] = tab_function
	added_boxes[input_box_name]["tab_function_params"] = params
end



function input_box.set_cursor(cursor_node)
	cursor_is_enabled = focused_box ~= nil and gui.is_enabled(focused_box["node"])
	cursor = cursor_node
	cursor_timer = timer.delay(cursor_interval, true, 
	function ()
		cursor_is_visible = not cursor_is_visible
		gui.set_enabled(cursor, cursor_is_visible and cursor_is_enabled)
	end)
end



local function update_cursor_position(action_id, action)
	if not cursor then
		return
	end

	if focused_box and gui.is_enabled(focused_box["node"]) then
		cursor_is_enabled = true
	else
		gui.set_enabled(cursor, false)
		cursor_is_enabled = false
		return
	end

	local node = focused_box["node"]

	if action or action_id then
		if not (action_id == action_name_tab or action_id == action_name_enter or action_id == action_name_backspace or action_id == action_name_text or (action_id == action_name_click and action.pressed and gui.pick_node(node, action.x, action.y))) then
			return
		end
	end
	
	local box_pos = gui.get_position(node)
	local new_x = box_pos["x"]
	local new_y = box_pos["y"]
	local text_width = gui.get_text_metrics_from_node(node)["width"]
	local text_height = gui.get_text_metrics_from_node(node)["height"]
	local pivot = gui.get_pivot(node)
	
	if pivot == gui.PIVOT_CENTER then
		new_x = new_x + text_width * 0.5
	elseif pivot == gui.PIVOT_W then
		new_x = new_x + text_width
	elseif pivot ~= gui.PIVOT_W then
		error("This pivot is not supported. Node: " .. gui.get_id(node), level)
	end
	

	gui.set_position(cursor, vmath.vector3(new_x , new_y, 0))
end



function input_box.set_action_name_backspace(name)
	action_name_backspace = hash(name)
end



function input_box.set_action_name_enter(name)
	action_name_enter = hash(name)
end



function input_box.set_action_name_tab(name)
	action_name_tab = hash(name)
end



function input_box.set_action_name_text(name)
	action_name_text = hash(name)
end



function input_box.set_action_name_click(name)
	action_name_click = hash(name)
end



function input_box.set_backspace_interval(interval)
	backspace_interval = interval
end



function input_box.set_backspace_delay(delay)
	backspace_delay = delay
end



function input_box.add(input_box_id, input_box_name, max_length)
	added_boxes[input_box_name] = {["node"] = gui.get_node(input_box_id), ["max_length"] = max_length or -1}
end



function input_box.set_focus(input_box_name)
	focused_box = added_boxes[input_box_name]
	update_cursor_position()
end



local function set_focus(input_box)
	focused_box = input_box
	update_cursor_position()
end



function input_box.on_input(action_id, action)
	
	if action_id == action_name_click then
		if action.pressed then
			for box_name, box in pairs(added_boxes) do
				if gui.pick_node(box["node"], action.x, action.y) and gui.is_enabled(box["node"]) then
					set_focus(box)
				end
			end
		end
	end


	if action_id == action_name_text then
		if focused_box then
			local cur_text = gui.get_text(focused_box["node"])
			if #cur_text < focused_box["max_length"] or focused_box["max_length"] == -1 then
				gui.set_text(focused_box["node"], cur_text .. action.text)
			end
		end
	end


	if action_id == action_name_backspace then
		if focused_box then
			if action["pressed"] then
				backspace_count = 0
			elseif not action["released"] then
				backspace_count = backspace_count + 1
			end

			if backspace_count == 0 or (backspace_count % backspace_interval == 0 and backspace_count > backspace_delay) then
				local cur_text = gui.get_text(focused_box["node"])
				gui.set_text(focused_box["node"], string.sub(cur_text, 1, #cur_text - 1))
			end
		end
	end


	if action_id == action_name_enter then
		if focused_box and action.pressed then
			if focused_box["enter_function"] then
				focused_box["enter_function"](focused_box["enter_function_params"])
			end
			
			if focused_box["enter_box"] then
				set_focus(focused_box["enter_box"])
			else
				set_focus(nil)
			end
		end
	end


	if action_id == action_name_tab then
		if focused_box and action.pressed then
			if focused_box["tab_function"] then
				focused_box["tab_function"](focused_box["tab_function_params"])
			end
			
			if focused_box["tab_box"] then
				set_focus(focused_box["tab_box"])
			end

		end
	end


	update_cursor_position(action_id, action)
end