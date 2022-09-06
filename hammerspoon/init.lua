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

-- Move Window
hyper:bind({''}, 'j', hs.grid.pushWindowDown)
hyper:bind({''}, 'k', hs.grid.pushWindowUp)
hyper:bind({''}, 'h', hs.grid.pushWindowLeft)
hyper:bind({''}, 'l', hs.grid.pushWindowRight)

hyper:bind({''}, 'x', hs.grid.pushWindowDown)
hyper:bind({''}, 'w', hs.grid.pushWindowUp)
hyper:bind({''}, 'a', hs.grid.pushWindowLeft)
hyper:bind({''}, 'd', hs.grid.pushWindowRight)


-- Resize Window
hyper:bind(hypermod, 'k', hs.grid.resizeWindowShorter)
hyper:bind(hypermod, 'j', hs.grid.resizeWindowTaller)
hyper:bind(hypermod, 'l', hs.grid.resizeWindowWider)
hyper:bind(hypermod, 'h', hs.grid.resizeWindowThinner)

hyper:bind(hypermod, 'x', hs.grid.resizeWindowShorter)
hyper:bind(hypermod, 'w', hs.grid.resizeWindowTaller)
hyper:bind(hypermod, 'a', hs.grid.resizeWindowWider)
hyper:bind(hypermod, 'd', hs.grid.resizeWindowThinner)


local windowSizeCache = {}
-- Toggle a window between its normal size, and being maximized
function toggle_window_maximized()
    local win = hs.window.focusedWindow()
    if windowSizeCache[win:id()] then
        win:setFrame(windowSizeCache[win:id()])
        windowSizeCache[win:id()] = nil
    else
        windowSizeCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- Maximize
hyper:bind({''}, 's', toggle_window_maximized)


-- Full screen
hyper:bind({''}, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Send Window Prev Monitor
hyper:bind({''},"p", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local previousScreen = win:screen():previous()
    win:moveToScreen(previousScreen)
    hs.alert.show("Prev Monitor", 5)
  end
end)


-- Send Window Next Monitor
hyper:bind({''}, "o", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
    hs.alert.show("Next Monitor", 5)
  end
end)

-- Show window hints
hyper:bind({''}, "i", function() hs.hints.windowHints() end)