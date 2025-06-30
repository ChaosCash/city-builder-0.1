local url = "http://127.0.0.1:8000/"
local content_type = nil
local request_body = nil

server = {}


function server.post(path, request_body, callback_function)
	if type(request_body) == "table" then
	content_type = "application/json"
	request_body = json.encode(request_body)
	else
	content_type = nil
	end

	http.request(
		ServerUrl .. path,
		"POST",
		callback_function or function() end,
		{["Content-Type"] = content_type},
		request_body
	)
end



	
