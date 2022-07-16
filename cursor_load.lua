--[[
CursorLoad -- part of the CursorMgr package
--]]


local cursorLoad = {}

--[[
This module provides some helper functions for loading mouse cursor graphics, hotspot metadata, and optionally a string ID to represent the cursor (based on the first part of the filename).


* Images with hotspot info embedded into the filenames:

The file name must be in this format:

`cool_cursor-hx_0_hy_1.<image_extension>`

Where the ID is everything in the file path from after the last forward slash to before the hyphen, and the hotspot position is encoded as tags (`hx_<n>` and `hy_<n>`) after the hyphen and before the next dot. The file name must contain only one hyphen. The image format + extension can be anything that LÖVE supports, but PNG is recommended. Leading paths (like `path/to/cursor-hx_0_hy_0.png`) will be trimmed.

Both hotspot tags are required, and it's an error if the function cannot find and parse them.


* Images with accompanying .hotspot files:

The cursor ID is the filename without the extension. A second file with the same name but `.hotspot` as its extension contains the hotspot data.
```
my_pointer.png
my_pointer.hotspot
```


'my_pointer.hotspot' should contain one tag per line:

```
hx 4
hy 8
```

Both tags must be present, or it will raise an error.

`hx` and `hy` must be integers greater than zero and less than the image width and height respectively.

--]]


-- * Internal *


local function getIntProperty(str, id, strict)

	local retval

	local i, j = string.find(str, id)
	if i then
		retval = tonumber(string.match(str, "%d+", j + 1))
	end

	if not retval and strict then
		error("missing cursor tag: " .. id)
	end

	return retval
end


-- * / Internal *


--- Utility function to parse the cursor ID and hotspot tags within filenames.
-- @param file_path Filename, optionally including the path (which will be trimmed) (forward slashes as separators only).
-- @return The ID, X hotspot and Y hotspot parsed from the file path.
function cursorLoad.getTagsFromFilePath(file_path)

	-- Remove leading path, if applicable.
	local id = string.match(file_path, "/*([^/]*)$")

	-- Separate ID and tagged regions
	local tag_str = string.match(id, "%-(.*)%..*$")

	id = string.match(id, "([^%-]*)%-")

	if not tag_str then
		error("couldn't extract tag substring from file path.")
	end

	local hx = getIntProperty(tag_str, "hx_", true)
	local hy = getIntProperty(tag_str, "hy_", true)

	return id, hx, hy
end


--- Load an image with tagged cursor metadata.
-- @param file_path Path and name of the image file.
-- @return ImageData created from the file path, and the ID, hotspot X and hotspot Y positions parsed from the file.
function cursorLoad.loadTaggedFile(file_path)

	local id, hx, hy = cursorLoad.getTagsFromFilePath(file_path)
	local i_data = love.image.newImageData(file_path)

	return i_data, id, hx, hy
end


--- Load an image with a paired .hotspot file containing cursor metadata.
-- @param file_path Path and name of the image file.
-- @param hotspot_path If the .hotspot file is not located in the same path as 'file_path', specify it here. Otherwise, leave this blank.
-- @return ImageData created from the file path, and the ID, hotspot X and hotspot Y positions parsed from the file.
function cursorLoad.loadFilePair(file_path, hotspot_path)

	local i_data = love.image.newImageData(file_path)

	hotspot_path = hotspot_path or (string.match(file_path, "(.*)%..*$") .. ".hotspot")

	-- Remove leading path, if applicable.
	local id = string.match(file_path, "/*([^/]*)$")
	id = string.match(id, "([^%.]*)%.")

	local hs_contents, size_or_err = love.filesystem.read("string", hotspot_path)

	if not hs_contents then
		error("failed to load .hotspot file: " .. tostring(size_or_err))
	end

	local hx = getIntProperty(hs_contents, "hx ", true)
	local hy = getIntProperty(hs_contents, "hy ", true)

	return i_data, id, hx, hy
end


return cursorLoad
