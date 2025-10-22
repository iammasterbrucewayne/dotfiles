hs = hs
hs.loadSpoon("AClock")

hs.hotkey.bind({ "cmd", "alt" }, "C", function()
	spoon.AClock:toggleShow()
end)

-- hammerspoon can be your next app launcher!!!!
hs.hotkey.bind({ "cmd", "alt" }, "A", function()
	hs.application.launchOrFocus("Arc")
	-- local arc = hs.appfinder.appFromName("Arc")
	-- arc:selectMenuItem({"Help", "Getting Started"})
end)

-- Application shortcuts (alternative to AeroSpace)
hs.hotkey.bind({ "alt" }, "V", function()
	hs.application.launchOrFocus("Vivaldi")
end)

hs.hotkey.bind({ "alt" }, "G", function()
	hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind({ "alt" }, "M", function()
	hs.application.launchOrFocus("Stremio")
end)

hs.hotkey.bind({ "alt" }, "U", function()
	hs.application.launchOrFocus("Cursor")
end)

hs.hotkey.bind({ "alt" }, "Y", function()
	-- Launch Vivaldi and open YouTube
	hs.application.launchOrFocus("Vivaldi")
	hs.timer.usleep(500000) -- Wait 0.5 seconds for Vivaldi to load
	hs.eventtap.keyStroke({"cmd"}, "t") -- Open new tab
	hs.timer.usleep(200000) -- Wait 0.2 seconds
	hs.eventtap.keyStrokes("youtube.com") -- Type URL
	hs.eventtap.keyStroke({}, "return") -- Press Enter
end)

hs.hotkey.bind({ "alt" }, "R", function()
	hs.reload()
end)
hs.alert.show("Config loaded")
