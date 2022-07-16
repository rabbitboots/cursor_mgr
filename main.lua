--[[
	This is a "stub" main.lua for LÖVE 11.4. Run a test or demo with:

	$ love . require_path_to_file

	Or run the default demo with just:

	$ love .
--]]

function love.load(arguments)
	local req_file = arguments[1] or "test_cursor_anim"

	require(req_file)
end
