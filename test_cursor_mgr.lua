--[[
A basic test of CursorMgr.

To run in LÖVE 11.4:
$ love . test_cursor_mgr

To run in LÖVE 12: (untested)
$ love test_cursor_mgr.lua

TODO: maybe merge this and the animated test, and also demonstrate the slot priority system.
--]]

--love.window.setVSync(0)

local cursorMgr = require("cursor_mgr")
local cursorLoad = require("cursor_load")

local cursor_mgr = cursorMgr.newManager(8)

-- Test cursorLoad functions

do
	local i_data, id, hx, hy
	i_data, id, hx, hy = cursorLoad.loadFilePair("demo_res/test_cursor.png")
	i_data, id, hx, hy = cursorLoad.loadTaggedFile("demo_res/test_cursor-hx_1_hy_1.png")

	local test_def = cursorMgr.newAnimatedCursorDef()
	
	local love_cursor = love.mouse.newCursor(i_data, hx, hy)
	local image = love.graphics.newImage(i_data)

	test_def.frames[1] = cursorMgr.newFrame(love_cursor, image, nil, hx, hy, math.huge)

	cursor_mgr.cursor_defs["test_cursor"] = test_def
end


do
	local def_arrow = cursor_mgr.cursor_defs["arrow"]
	local arrow_frame = def_arrow.frames[1]
	arrow_frame.image = love.graphics.newImage("demo_res/fallback_system_cursors/px_24/arrow-hx_6_hy_0.png")
	arrow_frame.hx = 6
	arrow_frame.hy = 0

	-- Make a default quad-cursor appear when no def is assigned.
	local d_frame = cursorMgr.default_frame
	d_frame.image = arrow_frame.image
	d_frame.hx = arrow_frame.hx
	d_frame.hy = arrow_frame.hy

	cursor_mgr:setDirty()
end


function love.keypressed(kc, sc)
	if sc == "escape" then
		love.event.quit()

	elseif sc == "tab" then
		cursor_mgr:setMode((cursor_mgr.mode == "hardware") and "texture" or "hardware")

	elseif sc == "1" then
		cursor_mgr:assignCursor()

	elseif sc == "2" then
		cursor_mgr:assignCursor("test_cursor")

	elseif sc == "f12" then
		love.window.setVSync(1 - love.window.getVSync())
	end
end


function love.mousefocus(focus)
	cursor_mgr:updateMouseFocus(focus)
end


function love.update(dt)
	cursor_mgr:refreshMouseState(dt)
end


function love.draw()
	cursor_mgr:drawCurrentFrame(love.mouse.getPosition())

	love.graphics.print("id_current:" .. tostring(cursor_mgr.id_current) ..
		"\nframe_i: " .. tostring(cursor_mgr.frame_i) ..
		"\ntimer: " .. tostring(cursor_mgr.timer) ..
		"\n\nTab: cursor mode: " .. cursor_mgr.mode ..
		"\n1: Set default cursor + fallback" ..
		"\n2: Set custom loaded cursor" ..
		"\nF12: VSync: " .. love.window.getVSync() .. " FPS: " .. love.timer.getFPS() ..
		"\n\nPress ESCAPE to quit!"
		, 16, 16
	)
end

