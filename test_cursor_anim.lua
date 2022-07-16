
--[[
Demonstrates an animated cursor with CursorMgr.

To run:
$ love .
--]]

local cursorMgr = require("cursor_mgr")

local cursor_mgr = cursorMgr.newManager(1)

local a_def
local scaled_dt = 0

love.keyboard.setKeyRepeat(true)

-- Backwards animation test region
local bw_x, bw_y, bw_w, bw_h = 8, 8, 160, 160

do
	local cur_w, cur_h = 64, 64
	local pad_x, pad_y = 64, 64

	local sheet = love.image.newImageData("demo_res/turbo_pointer_1000_alpha.png")

	a_def = cursorMgr.newAnimatedCursorDef()

	local i = 1
	for y = 0, 3 do
		for x = 0, 3 do
			local i_data = love.image.newImageData(cur_w, cur_h)
			i_data:paste(sheet, 0, 0, pad_x + x*cur_w, pad_y + y*cur_h, cur_w, cur_h)

			local image = love.graphics.newImage(i_data)
			local love_cursor = love.mouse.newCursor(i_data, 0, 0)
			a_def.frames[i] = cursorMgr.newFrame(love_cursor, image, nil, 0, 0, 1/20)

			i = i + 1
		end
	end

	cursor_mgr.cursor_defs["turbo_pointer_1000"] = a_def
	cursor_mgr:assignCursor("turbo_pointer_1000")
end


function love.keypressed(kc, sc)
	if sc == "escape" then
		love.event.quit()

	elseif sc == "tab" then
		cursor_mgr:setMode((cursor_mgr.mode == "hardware") and "texture" or "hardware")

	elseif sc == "f12" then
		love.window.setVSync(1 - love.window.getVSync())
	end
end


function love.mousefocus(focus)
	cursor_mgr:updateMouseFocus(focus)
end


local function distance(xa, ya, xb, yb)
	local dist_x = xa - xb
	local dist_y = ya - yb

	return math.sqrt(dist_x*dist_x + dist_y*dist_y)
end


function love.update(dt)
	local width, height = love.graphics.getDimensions()
	local cx, cy = width/2, height/2
	local mx, my = love.mouse.getPosition()

	local dist = distance(cx, cy, mx, my)

	scaled_dt = (dt * math.max(0, 400 - dist) / 128)

	if mx >= bw_x and mx < bw_x + bw_w and my >= bw_y and my < bw_y + bw_h then
		scaled_dt = -dt
	end

	cursor_mgr:refreshMouseState(scaled_dt)
end


function love.draw()

	love.graphics.push("all")

	local width, height = love.graphics.getDimensions()
	local cx, cy = width/2, height/2
	local mx, my = love.mouse.getPosition()

	love.graphics.setColor(0.14,0.24,0.36,1)
	love.graphics.setLineWidth(2)
	love.graphics.line(cx, 0, cx, height)
	love.graphics.line(0, cy, width, cy)

	love.graphics.setColor(0.8, 0.2, 0.2, 1)
	love.graphics.rectangle("fill", bw_x, bw_y, bw_w, bw_h)
	love.graphics.setColor(1,1,1,1)

	love.graphics.print("Reverse animation", bw_x + 4, bw_y + 4)

	love.graphics.print("Move mouse towards center of window to speed up the cursor animation."
		.. "\nPress TAB to toggle between hardware and texture cursors: " .. cursor_mgr.mode
		.. "\n(F12) Vsync: " .. love.window.getVSync() .. " (FPS: " .. love.timer.getFPS() .. ")"
		.. "\n\nPress ESCAPE to quit!"
		, 16, 310)

	love.graphics.print("id_current: " .. tostring(cursor_mgr.id_current) ..
		"\nframe_i: " .. tostring(cursor_mgr.frame_i) ..
		"\ntimer: " .. tostring(cursor_mgr.timer)
		, 16, 400
	)

	love.graphics.pop()

	-- Draw quad-based cursor if HW cursor mode is not active.
	cursor_mgr:drawCurrentFrame(love.mouse.getPosition())
end

