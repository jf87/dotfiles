hyper = require('hyper')

------------------------
-- Jamf admin request
------------------------
local jamf = require('jamf')
hyper:bind({''}, 'e', jamf.request)

------------------------
-- Reload
------------------------
local function reloadConfig()
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

------------------------
-- Window management
------------------------

-- All window state lives in one table, keyed by window id where relevant.
--   left/right: presence of a window's id toggles quarter <-> half on that side
--   maxCache/maxState: the maximize cycle (normal -> half -> full -> normal)
local state = { left = {}, right = {}, maxCache = {}, maxState = 0 }

local function resetState()
  state.left = {}
  state.right = {}
  state.maxCache = {}
  state.maxState = 0
end

-- Focused window, or nil (with a toast) when there is none.
local function focused()
  local win = hs.window.focusedWindow()
  if not win then hs.alert.show("No focused window") end
  return win
end

-- Left: quarter <-> half
hyper:bind({''}, "a", function()
  local win = focused(); if not win then return end
  state.right = {}
  state.maxCache = {}
  state.maxState = 0
  local id = win:id()
  if state.left[id] then
    win:moveToUnit(hs.layout.left50)
    state.left[id] = nil
  else
    state.left[id] = win:frame()
    win:moveToUnit(hs.layout.left25)
  end
end)

-- Right: quarter <-> half
hyper:bind({''}, "d", function()
  local win = focused(); if not win then return end
  state.left = {}
  state.maxCache = {}
  state.maxState = 0
  local id = win:id()
  if state.right[id] then
    win:moveToUnit(hs.layout.right50)
    state.right[id] = nil
  else
    state.right[id] = win:frame()
    win:moveToUnit(hs.layout.right25)
  end
end)

-- Top half
hyper:bind({''}, "w", function()
  local win = focused(); if not win then return end
  resetState()
  local f = win:frame()
  local max = win:screen():frame()
  f.x = max.x
  f.y = 0
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Bottom half
hyper:bind({''}, "x", function()
  local win = focused(); if not win then return end
  resetState()
  local f = win:frame()
  local max = win:screen():frame()
  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

-- Maximize cycle: centered half -> full -> original
local function toggleMaximized()
  local win = focused(); if not win then return end
  state.left = {}
  state.right = {}
  local id = win:id()
  local max = win:screen():frame()
  if state.maxState == 0 then
    state.maxCache[id] = win:frame()
    local f = win:frame()
    f.h = max.h
    f.w = max.w / 2
    win:setFrame(f)
    win:centerOnScreen()
    state.maxState = 1
  elseif state.maxState == 1 then
    win:maximize()
    state.maxState = 2
  elseif state.maxState == 2 and state.maxCache[id] then
    win:setFrame(state.maxCache[id])
    state.maxCache[id] = nil
    state.maxState = 0
  else
    state.maxCache[id] = nil
    state.maxState = 0
  end
end
hyper:bind({''}, 's', toggleMaximized)

-- Full screen
hyper:bind({''}, 'f', function()
  local win = focused(); if not win then return end
  win:toggleFullScreen()
end)

-- Send window to previous monitor
hyper:bind({''}, "p", function()
  if #hs.screen.allScreens() <= 1 then return end
  local win = focused(); if not win then return end
  win:moveToScreen(win:screen():previous())
  resetState()
  hs.alert.show("Prev Monitor", 1)
end)

-- Send window to next monitor
hyper:bind({''}, "o", function()
  if #hs.screen.allScreens() <= 1 then return end
  local win = focused(); if not win then return end
  win:moveToScreen(win:screen():next())
  resetState()
  hs.alert.show("Next Monitor", 1)
end)

-- Show window hints
hyper:bind({''}, "i", function() hs.hints.windowHints() end)
