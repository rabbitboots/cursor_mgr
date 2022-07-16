--[[
Move the mouse to the left or right half of the window to change the low-priority cursor.
Press space to toggle the high-priority cursor.

To run:
$ love . barebones_example
--]]

local cursorMgr = require("cursor_mgr")

local cursor_mgr = cursorMgr.newManager(2) -- Two priority levels

local override = false

function love.keypressed(keycode, scancode)
	if scancode == "space" then
		if override == "wait" then
			override = false
		else
			override = "wait"
		end
	end
end

function love.update(dt)
	local w = love.graphics.getWidth()
	local x = love.mouse.getX()

	-- Set low-priority cursor
	if x > w/2 then
		cursor_mgr:assignCursor("hand", 2)
	else
		cursor_mgr:assignCursor("crosshair", 2)
	end

	-- Set high-priority cursor.
	cursor_mgr:assignCursor(override, 1)

	-- Update the manager object
	cursor_mgr:refreshMouseState(dt)
end
