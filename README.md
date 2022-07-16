**NOTE**: This is currently a beta.

# CursorMgr

CursorMgr is a library for LÖVE that handles mouse cursors. Features include:

* Priority slot system: only the highest-priority cursor is displayed

* Two display modes: hardware (part of the OS) and texture (rendered in `love.draw()`)

* Support for animated cursors

* Cursors are referenced by string ID, so source files don't require direct access to LÖVE Cursor objects


## Supported LÖVE Versions

* LÖVE 11.4

NOTE: the system must support cursors for this and the companion modules to work. You can check with [love.mouse.isCursorSupported](https://love2d.org/wiki/love.mouse.isCursorSupported).


## Barebones Example

Here's a basic example, which creates a manager object containing only the built-in hardware cursors and two priority slots.

```lua
--[[
Move the mouse to the left or right half of the window to change the low-priority cursor.
Press space to toggle the high-priority cursor.
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
```

## Custom Cursors

Using custom cursors is a bit more involved. You will have to write some code to make animated cursor definitions. (Internally, static and animated cursors are the same table structure, with static cursors containing one frame and a duration of infinity.) CursorMgr does not handle this for you because there are a number of ways to approach it, and they all involve loading resources of some kind and pulling in hotspot metadata. That said, `cursor_load.lua` provides some ways of loading ImageData and hotspot tags from disk with `love.filesystem`.

See `test_cursor_mgr.lua` for an example of a fallback texture cursor, and `test_cursor_anim.lua` for an animated cursor demo.


## Cursor Storage

Cursor definitions are stored in the `cursor_mgr` table like this:

```
self.cursor_defs[ID hash]
	^ AnimCursorDefs
		.loop_point = <n> -- Which frame to return to when looping (forward animation only)
		.frames {
			.love_cursor -- HW cursor object
			.image -- Used with texture mode
			.quad -- Optional quad to go with .image
			.hx -- X hotspot for texture mode
			.hy -- Y hotspot for texture mode
			.duration -- Frame time, in seconds. (math.huge == don't animate)
```

`love_cursor` needs to be assigned a LÖVE Cursor object if you want to use it in hardware mode. For texture mode, `image`, `quad`, `hx` and `hy` must be populated.


## I need more cursors!

Check out [MouseCursorPack](https://github.com/rabbitboots/mouse_cursor_pack).


## Known issues

* Windows, LÖVE 11.4: custom mouse cursors may be scaled to dimensions that conform to the system's cursor scaling. For example, a large cursor may be scaled down to roughly the same size as the default arrow. This was caused by a minor regression in SDL2. It should be fixed if you build LÖVE 11.4 with [megasource](https://github.com/love2d/megasource). (More info [here](https://github.com/love2d/love/issues/1762) and [here](https://github.com/libsdl-org/SDL/issues/5198).)

* Windows 10: custom cursors are scaled by the current cursor size setting. This is generally good behavior, but it means that if you design an oversized custom cursor, it could appear even more oversized, depending on the user's OS settings. On Linux (Fedora 36), custom cursors are not scaled according to the system cursor size alone. I currently don't have a solution to this, other than to try rendering the cursors in texture mode as part of `love.draw()`.

* Extremely large hardware cursors may flicker, or have single-frame artifacts when switching to them.

* Windows 10: changing the hardware cursor while VSync is disabled may lead to occasional flickering. This isn't too noticeable when switching between static cursors, but may be a problem with animated cursors.

* Switching between hardware cursors of different sizes may lead to single-frame artifacts.

* The motion of non-hardware texture cursors may feel delayed. This will depend on the user's monitor refresh rate, and if VSync is enabled.


**BETA NOTE**: The Windows 10 issues may just be related to the fact that my Windows PC is a 10 year old laptop. Needs testing on newer hardware, and Windows 11. I haven't tested Mac yet due to not currently owning one -- ditto for high-dpi monitors. YMMV.
