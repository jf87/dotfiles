hyper = require('hyper')
local hypermod = {"cmd"}

------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")

------------------------
-- Window Managment
------------------------
local windowSizeCacheRight = {}
local windowSizeCacheLeft = {}

-- hyper:bind({''}, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left25) end)
hyper:bind({''}, "a", function()
	-- windowSizeCacheRight = {}
	windowSizeCache = {}
	windowSizeCacheState = 0
	windowSizeCacheRight = {}
  local win = hs.window.focusedWindow()
  if windowSizeCacheLeft[win:id()] then
	  win:moveToUnit(hs.layout.left50)
      windowSizeCacheLeft[win:id()] = nil
  else
      windowSizeCacheLeft[win:id()] = win:frame()
	  win:moveToUnit(hs.layout.left25)
  end
end)




-- hyper:bind({''}, 'd', function() hs.window.focusedWindow():moveToUnit(hs.layout.right25) end)
hyper:bind({''}, "d", function()
	-- windowSizeCacheLeft = {}
	windowSizeCache = {}
	windowSizeCacheState = 0
	windowSizeCacheLeft = {}
  local win = hs.window.focusedWindow()
  if windowSizeCacheRight[win:id()] then
	  win:moveToUnit(hs.layout.right50)
      windowSizeCacheRight[win:id()] = nil
  else
      windowSizeCacheRight[win:id()] = win:frame()
	  win:moveToUnit(hs.layout.right25)
  end
end)


hyper:bind({''}, "w", function()
	windowSizeCacheLeft = {}
	windowSizeCacheRight = {}
	windowSizeCache = {}
	windowSizeCacheState = 0
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = 0
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hyper:bind({''}, "x", function()
	windowSizeCacheLeft = {}
	windowSizeCacheRight = {}
	windowSizeCache = {}
	windowSizeCacheState = 0
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)


local windowSizeCache = {}
local windowSizeCacheState = 0
-- Toggle a window between its normal size, and being maximized
function toggle_window_maximized()
	windowSizeCacheLeft = {}
	windowSizeCacheRight = {}	
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()
	if windowSizeCacheState == 0 then
        windowSizeCache[win:id()] = win:frame()
		f.h = max.h
		f.w = max.w/2
		win:setFrame(f)
		win:centerOnScreen()
		windowSizeCacheState = 1
	elseif windowSizeCacheState == 1 then
        win:maximize()
		windowSizeCacheState = 2
	elseif windowSizeCacheState == 2 and windowSizeCache[win:id()] then
        win:setFrame(windowSizeCache[win:id()])
        windowSizeCache[win:id()] = nil
		windowSizeCacheState = 0
	else
       windowSizeCache[win:id()] = nil
	   windowSizeCacheState = 0
    end
end

-- Maximize
hyper:bind({''}, 's', toggle_window_maximized)


-- hyper:bind({''},  "q", function()
-- 	local win = hs.window.focusedWindow()
-- 	local f = win:frame()
-- 	local screen = win:screen()
-- 	local max = screen:frame()
--
-- 	f.h = max.h
-- 	f.w = max.w/2
-- 	win:setFrame(f)
-- 	win:centerOnScreen()
-- end)


-- Move Window
-- hyper:bind({''}, 'j', hs.grid.pushWindowDown)
-- hyper:bind({''}, 'k', hs.grid.pushWindowUp)
-- hyper:bind({''}, 'h', hs.grid.pushWindowLeft):
-- hyper:bind({''}, 'l', hs.grid.pushWindowRight)
-- --
-- -- hyper:bind({''}, 'x', hs.grid.pushWindowDown)
-- -- hyper:bind({''}, 'w', hs.grid.pushWindowUp)
-- -- hyper:bind({''}, 'a', hs.grid.pushWindowLeft)
-- -- hyper:bind({''}, 'd', hs.grid.pushWindowRight)
--
--
-- -- Resize Window
-- hyper:bind(hypermod, 'k', hs.grid.resizeWindowShorter)
-- hyper:bind(hypermod, 'j', hs.grid.resizeWindowTaller)
-- hyper:bind(hypermod, 'l', hs.grid.resizeWindowWider)
-- hyper:bind(hypermod, 'h', hs.grid.resizeWindowThinner)
--
-- -- hyper:bind(hypermod, 'x', hs.grid.resizeWindowShorter)
-- -- hyper:bind(hypermod, 'w', hs.grid.resizeWindowTaller)
-- -- hyper:bind(hypermod, 'a', hs.grid.resizeWindowWider)
-- -- hyper:bind(hypermod, 'd', hs.grid.resizeWindowThinner)




-- Full screen
hyper:bind({''}, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Send Window Prev Monitor
hyper:bind({''},"p", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local previousScreen = win:screen():previous()
    win:moveToScreen(previousScreen)
	windowSizeCacheLeft = {}
	windowSizeCacheRight = {}
	windowSizeCache = {}
	windowSizeCacheState = 0
    hs.alert.show("Prev Monitor", 5)
  end
end)


-- Send Window Next Monitor
hyper:bind({''}, "o", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
	windowSizeCacheLeft = {}
	windowSizeCacheRight = {}
	windowSizeCache = {}
	windowSizeCacheState = 0
    hs.alert.show("Next Monitor", 5)
  end
end)

-- Show window hints
hyper:bind({''}, "i", function() hs.hints.windowHints() end)