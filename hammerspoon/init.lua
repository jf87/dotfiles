require("hyper")
-- Hammerspoon config based on
-- https://github.com/oschrenk/dotfiles/blob/master/.hammerspoon/init.lua 
-- https://github.com/cmsj/hammerspoon-config


-- Requirements
-- Unsupported Spaces extension. Uses private APIs but works okay.
-- (http://github.com/asmagill/hammerspoon_asm.undocumented)
--spaces = require("hs._asm.undocumented.spaces")
require("hs.application")
hotkey = require "hs.hotkey"
window = require "hs.window"
spaces = require "hs._asm.undocumented.spaces"

--------------------------
-- Settings
--------------------------

-- Network

local wifiInterface = "en0"
local wifiWatcher = nil
local workSSIDToken = "NEC-Oa"
local homeSSIDToken = "Tortugawifi 🐢"
local homeSSIDs = {"Tortugawifi 🐢","autobahn", "keinkabel02", "keinkabel01" }
local lastSSID = hs.wifi.currentNetwork()
local homeLocation = "Home"
local workLocation = "Work"


-- Define monitor names for layout purposes
local display_laptop = "Color LCD"
local display_monitor1 = "DELL U2711"
local display_monitor2 = "EA221WM"

-- Define audio device names for headphone/speaker switching
local headphoneDevice = "External Headphones"
local speakerDevice = "Scarlett 2i4 USB"

-- disable animation
hs.window.animationDuration = 0

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}
--local config = require('hyper')
--local hyper = config.k
------------------------
---- Internal state
--------------------------

local windowSizeCache = {}

------------------------
-- Window Managment
------------------------

-- Half Windows
hs.hotkey.bind(hyper, 'a', function() hs.window.focusedWindow():moveToUnit(hs.layout.left50) end)
hs.hotkey.bind(hyper, 'd', function() hs.window.focusedWindow():moveToUnit(hs.layout.right50) end)
hs.hotkey.bind(hyper, "w", function()
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
hs.hotkey.bind(hyper, "x", function()
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
hs.hotkey.bind(hyper, 's', toggle_window_maximized)

-- Full screen
hs.hotkey.bind(hyper, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Send Window Prev Monitor
hs.hotkey.bind(hyper, "p", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local previousScreen = win:screen():previous()
    win:moveToScreen(previousScreen)
    hs.alert.show("Prev Monitor", 5)
  end
end)

-- Send Window Next Monitor
hs.hotkey.bind(hyper, "o", function()
  if (#hs.screen.allScreens() > 1) then
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
    hs.alert.show("Next Monitor", 5)
  end
end)

-- Show window hints
hs.hotkey.bind(hyper, "i", function() hs.hints.windowHints() end)

-- Focus Windows
hs.hotkey.bind(hyper, 'k', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(hyper, 'j', function() hs.window.focusedWindow():focusWindowSouth() end)
hs.hotkey.bind(hyper, 'l', function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind(hyper, 'h', function() hs.window.focusedWindow():focusWindowWest() end)

-- Close notifications
script = [[
my closeNotif()
on closeNotif()
    tell application "System Events"
        tell process "Notification Center"
            set theWindows to every window
            repeat with i from 1 to number of items in theWindows
                set this_item to item i of theWindows
                try
                    click button 1 of this_item
                on error
                    my closeNotif()
                end try
            end repeat
        end tell
    end tell
end closeNotif ]]
function clearNotifications()
  ok, result = hs.applescript(script)
end
hs.hotkey.bind(hyper, "c", function()
  hs.alert.show("Closing notifications")
  hs.timer.doAfter(0.3, clearNotifications)
end)

hs.hotkey.bind(hyper, "q", function ()
  focusScreen(hs.window.focusedWindow():screen():previous())
end)

--Predicate that checks if a window belongs to a screen
function isInScreen(screen, win)
  return win:screen() == screen
end

function focusScreen(screen)
  --Get windows within screen, ordered from front to back.
  --If no windows exist, bring focus to desktop. Otherwise, set focus on
  --front-most application window.
  local windows = hs.fnutils.filter(
      hs.window.orderedWindows(),
      hs.fnutils.partial(isInScreen, screen))
  local windowToFocus = #windows > 0 and windows[1] or hs.window.desktop()
  windowToFocus:focus()

  -- Move mouse to center of screen
  local pt = hs.geometry.rectMidPoint(screen:fullFrame())
  hs.mouse.setAbsolutePosition(pt)
  hs.eventtap.leftClick(pt)

end

--------------------------------------------------------------------------------


------------------------
-- Spaces
------------------------
-- Gets a list of windows and iterates until the window title is non-empty.
-- This avoids focusing the hidden windows apparently placed on top of all
-- Google Chrome windows. It also checks if the empty title belongs to Chrome,
-- because some apps don't give any of their windows a title, and should still
-- be focused.
local function spaceChange()
  visibleWindows = hs.window.orderedWindows()
  for i, window in ipairs(visibleWindows) do
    if window:application():title() == "Google Chrome" then
      if window:title() ~= "" then
        window:focus()
        break
      end
    else
      window:focus()
      break
    end
  end
end


function getGoodFocusedWindow(nofull)
   local win = window.focusedWindow()
   if not win or not win:isStandard() then return end
   if nofull and win:isFullScreen() then return end
   return win
end 

function flashScreen(screen)
   local flash=hs.canvas.new(screen:fullFrame()):appendElements({
	 action = "fill",
	 fillColor = { alpha = 0.25, red=1},
	 type = "rectangle"})
   flash:show()
   hs.timer.doAfter(.15,function () flash:delete() end)
end 

function switchSpace(skip,dir)
   for i=1,skip do
      hs.eventtap.keyStroke({"ctrl"},dir)
   end 
end


-- thi sees eprecated...
function moveWindowOneSpace(dir,switch)
   --local win = getGoodFocusedWindow(true)
   --if not win then return end
   --local screen=win:screen()
   --print(screen)
   --local uuid = screen:spacesUUID()
   win = hs.window.focusedWindow()
   uuid = win:screen():spacesUUID()
   print(uuid)
   local userSpaces=nil
   for k,v in pairs(spaces.layout()) do
      userSpaces=v
      if k==uuid then break end
   end
   if not userSpaces then return end
   local thisSpace=win:spaces() -- first space win appears on
   if not thisSpace then return else thisSpace=thisSpace[1] end
   local last=nil
   local skipSpaces=0
   for _, spc in ipairs(userSpaces) do
      if spaces.spaceType(spc)~=spaces.types.user then -- skippable space
	 skipSpaces=skipSpaces+1
      else 			-- A good user space, check it
	 if last and
	    ((dir=="left"  and spc==thisSpace) or
	     (dir=="right" and last==thisSpace))
	 then
	    win:spacesMoveTo(dir=="left" and last or spc)
	    if switch then
	       switchSpace(skipSpaces+1,dir)
	       win:focus()
	    end
	    return
	 end
	 last=spc	 -- Haven't found it yet...
	 skipSpaces=0
      end 
   end
   flashScreen(screen)   -- Shouldn't get here, so no space found
end


local mouseOrigin
local inMove=0
-- move a window to an adjacent Space
function moveWindowOneSpaceOld(direction)
   local win = window.focusedWindow()
   if not win then return end
   local clickPoint = win:zoomButtonRect()
   if inMove==0 then mouseOrigin = hs.mouse.getAbsolutePosition() end
   
   clickPoint.x = clickPoint.x + clickPoint.w + 5
   clickPoint.y = clickPoint.y + (clickPoint.h / 2)
   local mouseClickEvent = hs.eventtap.event.newMouseEvent(
      hs.eventtap.event.types.leftMouseDown, clickPoint)
   mouseClickEvent:post()
   
   local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent(
      {"ctrl"},direction, true)
   nextSpaceDownEvent:post()
   inMove=inMove+1		-- nested moves possible, ensure reentrancy

   hs.timer.doAfter(.1,function()
		       local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent(
			  {"ctrl"}, direction, false)
		       nextSpaceUpEvent:post()
		       -- wait to release the mouse to avoid sticky window syndrome
		       hs.timer.doAfter(.25, 
					function()
					   local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(
					      hs.eventtap.event.types.leftMouseUp, clickPoint)
					   mouseReleaseEvent:post()
					   inMove=math.max(0,inMove-1)
					   if inMove==0 then hs.mouse.setAbsolutePosition(mouseOrigin) end 
		       end)
   end)
end

function moveWindowOneSpaceOldOld(direction)
   local mouseOrigin = hs.mouse.getAbsolutePosition()
   local win = hs.window.focusedWindow()
   local clickPoint = win:zoomButtonRect()

   clickPoint.x = clickPoint.x + clickPoint.w + 5
   clickPoint.y = clickPoint.y + (clickPoint.h / 2)

   local mouseClickEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint)
   mouseClickEvent:post()
   hs.timer.usleep(350000)

   local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, true)
   nextSpaceDownEvent:post()
   hs.timer.usleep(350000)

   local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, false)
   nextSpaceUpEvent:post()
   hs.timer.usleep(350000)

   local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint)
   mouseReleaseEvent:post()
   hs.timer.usleep(350000)

  hs.mouse.setAbsolutePosition(mouseOrigin)
  spaceChange()
end


mash = {"ctrl", "cmd"}

hk1 = hs.hotkey.bind(mash, "m",
             function() moveWindowOneSpaceOldOld("right",true) end)
hk2 = hs.hotkey.bind(mash, "n",
             function() moveWindowOneSpaceOldOld("left",true) end)


--------------------------------------------------------------------------------


------------------------
-- Bluetooth
------------------------
-- relies on https://github.com/toy/blueutil
-- installable via `brew install blueutil`

function enableBluetooth()
  hs.alert.show("Enabling Bluetooth")
  os.execute("/usr/local/bin/blueutil -p 1")
end

function disableBluetooth()
  hs.alert.show("Disabling Bluetooth")
  os.execute("/usr/local/bin/blueutil -p 0")
end

function bluetoothEnabled()
  local file = assert(io.popen('/usr/local/bin/blueutil -p', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "") == "1"
end

hs.hotkey.bind(hyper, "b", function()
  if (bluetoothEnabled()) then
    disableBluetooth()
  else
    enableBluetooth()
  end
end)


------------------------
-- WiFi
------------------------

function wifiEnabled()
  local file = assert(io.popen('/usr/sbin/networksetup -getairportpower ' .. wifiInterface, 'r'))
  local output = file:read('*all')
  file:close()

  return string.match(output, ":%s(%a+)") == "On"
end

function enableWifi()
  os.execute("/usr/sbin/networksetup -setairportpower " .. wifiInterface .. " on")
  hs.alert.show("Enabled Wifi")
end

function disableWifi()
  hs.alert.show("Disabled Wifi")
  os.execute("/usr/sbin/networksetup -setairportpower " .. wifiInterface .. " off")
end

-- Toggle wifi
hs.hotkey.bind(hyper, "v", function()
  if (wifiEnabled()) then
    disableWifi()
  else
    enableWifi()
  end
end)

------------------------
-- Audio settings
------------------------

-- Toggle between speaker and headphone sound devices (useful if you have multiple USB soundcards that are always connected)
function toggle_audio_output()
    local current = hs.audiodevice.defaultOutputDevice()
    local speakers = hs.audiodevice.findOutputByName(speakerDevice)
    local headphones = hs.audiodevice.findOutputByName(headphoneDevice)

    if not speakers or not headphones then
        hs.notify.new({title="Hammerspoon", informativeText="ERROR: Some audio devices missing", ""}):send()
        return
    end

    if current:name() == speakers:name() then
        headphones:setDefaultOutputDevice()
    else
        speakers:setDefaultOutputDevice()
    end
    hs.notify.new({
          title='Hammerspoon',
            informativeText='Default output device:'..hs.audiodevice.defaultOutputDevice():name()
        }):send()
end

hs.hotkey.bind(hyper, 'y', toggle_audio_output)


-- no need, use function keys
--hs.hotkey.bind(hyper, 'm', mute)

------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")
