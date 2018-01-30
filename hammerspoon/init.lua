-- Hammerspoon config based on
-- https://github.com/oschrenk/dotfiles/blob/master/.hammerspoon/init.lua 
-- https://github.com/cmsj/hammerspoon-config


-- Requirements
-- Unsupported Spaces extension. Uses private APIs but works okay.
-- (http://github.com/asmagill/hammerspoon_asm.undocumented)
spaces = require("hs._asm.undocumented.spaces")
require("hs.application")

--------------------------
-- Settings
--------------------------

-- Network

local wifiInterface = "en0"
local wifiWatcher = nil
local workSSIDToken = "ITU++"
local homeSSIDToken = "autobahn_5GHz"
local homeSSIDs = {"autobahn_5GHz","autobahn", "keinkabel02", "keinkabel01" }
local lastSSID = hs.wifi.currentNetwork()
local homeLocation = "Home"
local workLocation = "Work"


-- Fast User Switching
-- `id -u` to find curent id
local personalUserId = "502"
local workUserId     = "503"

-- Define monitor names for layout purposes
local display_laptop = "Color LCD"
local display_monitor1 = "DELL U2711"
local display_monitor2 = "2460"

-- Define audio device names for headphone/speaker switching
local headphoneDevice = "Headphones"
local speakerDevice = "Scarlett 2i4 USB"

-- How often to update Fan and Temp
updateStatsInterval = 20

-- disable animation
hs.window.animationDuration = 0

-- hotkey hyper
local hyper = {"ctrl", "alt", "shift", "cmd"}

------------------------
---- Internal state
--------------------------

local windowSizeCache = {}
local spotifyWasPlaying = false
local powerSource = hs.battery.powerSource()


------------------------
-- MenuBar
------------------------

-- Get output of a bash command
function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Reimplemented version of capture() because sometimes Lua
-- fails with "interrupted system call" when using io.popen() on OS X
-- This is ugly, don't use it! Better use hs.task
function mCapture(cmd, raw)
   local tmpfile = os.tmpname()
   os.execute(cmd .. ">" .. tmpfile)
   local f=io.open(tmpfile)
   local s=f:read("*a")
   f:close()
   os.remove(tmpfile)
   if raw then return s end
   s = string.gsub(s, '^%s+', '')
   s = string.gsub(s, '%s+$', '')
   s = string.gsub(s, '[\n\r]+', ' ')
   return s
end

function getMean(s)
    local n, j
    n = 0
    j = 0
    for i in string.gmatch(s, "%S+") do
        j = j + 1
        n = tonumber(i)+n
    end
    n = math.floor(n/j)
    return tostring(n)
end


-- Update the fan and temp. Needs iStats CLI tool from homebrew.
-- gem install iStats
local function updateStats()
  fanSpeed = mCapture("/usr/local/bin/istats fan speed | cut -c14- | sed 's/\\..*//'", false)
  temp = mCapture("/usr/local/bin/istats cpu temp | cut -c11- | sed 's/\\..*//'", false)
  fanSpeed = getMean(fanSpeed)
end

-- Makes (and updates) the topbar menu filled with the current Space, the
-- temperature and the fan speed. The Space only updates if the space is changed
-- with the Hammerspoon shortcut (option + arrows does not work). 
local function makeStatsMenu(calledFromWhere)
  if statsMenu == nil then
    statsMenu = hs.menubar.new()
  end
  if calledFromWhere == "spaceChange" then
    currentSpace = tostring(spaces.currentSpace()) 
  else
    updateStats()
  end
  -- statsMenu:setTitle("Space " .. currentSpace .. " | Fan: " .. fanSpeed .. " | Temp: " .. temp)
  statsMenu:setTitle("".. currentSpace .. " | " .. fanSpeed .. " RPM | " .. temp .. "°C")
end


statsMenuTimer = hs.timer.new(updateStatsInterval, makeStatsMenu)
statsMenuTimer:start()

------------------------------------------------------------------------------
-- ChangeResolution
------------------------------------------------------------------------------
-- Modal hotkey to change a monitors resolution
-- Also includes basic menu bar item, which is dynamically generated
-- You do have to set the resolutions you want manually, and if
-- you have multiple computers, you'll have to apply the layouts
-- appropriately
--
-- [ ] should make this it's own extension/file
-- [ ] check the menu bar item corresponding to current res
------------------------------------------------------------------------------
--
--

function getScreens()
	screens = hs.screen.allScreens()
	return screens
end


-- possible resolutions for 15 MBPr
local laptopResolutions = {
  {w = 1440, h = 900, s = 2},
  {w = 1680, h = 1050, s = 2},
  {w = 1920, h = 1200, s = 2},
  {w = 2048, h = 1280, s = 1},
  {w = 2560, h = 1600, s = 1},
  {w = 2880, h = 1800, s = 1}
}

-- possible resolutions for 4k Dell monitor
local desktopResolutions = {
  -- first 1920 is for retina resolution @ 30hz
  -- might not be neede as 2048 looks pretty good
  {w = 1920, h = 1080, s = 2},
  -- this 1920 is for non-retina @ 60hz
  {w = 1920, h = 1080, s = 1},
  {w = 2048, h = 1152, s = 2},
  {w = 2304, h = 1296, s = 2},
  {w = 2560, h = 1440, s = 2}
}


local mbairResolutions = {
  {w = 1440, h = 900, s = 1},
  {w = 1440, h = 900, s = 1}
}
-- initialize variable to ultimately store the correct set of resolutions
local resolutions = {}
local choices = {}
local dropdownOptions = {}

-- find out which set we need
if hs.host.localizedName() == "iMac" then
  resolutions = desktopResolutions
elseif hs.host.localizedName() == "MacBook Pro" then
  resolutions = laptopResolutions
elseif hs.host.localizedName() == "MacBook Air" then
  resolutions = mbairResolutions
else
  print('no resolutions available for this computer/monitor')
  print(hs.host.localizedName())
end

-- configure the modal hotkeys
-- has some entered/exit options, mainly to show/hide available options on
-- entry/exit
function setupResModal()
  k = hs.hotkey.modal.new('cmd-alt-ctrl', 'l')
  k:bind('', 'escape', function() hs.alert.closeAll() k:exit() end)

  -- choices table is for storing the widths to display with hs.alert later
  -- this is necessary because possible resolutions vary based on display
  for i = 1, #resolutions do
    -- inserts resolutions width in to choices table so we can iterate through them easily later
    table.insert(choices, resolutions[i].w)
    -- also creates a table to pass to init our dropdown menu with menuitem title and callback (this is fucking ugly)
    table.insert(dropdownOptions, {title = tostring(i) .. ": " .. tostring(choices[i]), fn = function() return processKey(i) end, checked = false })
    k:bind({}, tostring(i), function () processKey(i) end)
  end

  -- function to display the choices as an alert
  -- called on hotkey modal entry
  function displayChoices()
    for i = 1, #choices do
      hs.alert(tostring(i) .. ": " .. choices[i], 99)
    end
  end

  -- on modal entry, display choices
  function k:entered() displayChoices() end
  -- on model exit, clear all alerts
  function k:exited() hs.alert.closeAll() end

end

-- processes the key from modal binding
-- resolution array is also passed so we can grab the corresponding resolution
-- then calls changeRes function with hte values we want to change to
function processKey(i)
  -- would be cool to check the menu bar option that is currently selected,
  -- but it seems like a bit of a pain in the ass, because I think I'd have to reinitialize
  -- all the menubar items, since I'd have to change check to false for current,
  -- and true for new selection
  local res = resolutions[tonumber(i)]

  hs.alert("Setting resolution to: " .. res.w .. " x " .. res.h, 5)
  changeRes(res.w, res.h, res.s)

  setResolutionDisplay(res.w)

  k:exit()
end

-- desktop resolutions in form {w, h, scale} to be passed to setMode
function changeRes(w, h, s)
	local screens = getScreens()
	for k,v in pairs(screens) do
		if v:name() == display_laptop then
			v:setMode(w, h, s)
		end
		print(k,v)
	end
	--hs.screen.primaryScreen():setMode(w, h, s)
end

setupResModal()

-- Initializes a menubar item that displays the current resolution of display
-- And when clicked, toggles between two most commonly used resolutions
print(resolutions[0])
if next(resolutions) ~= nil then
    local resolutionMenu = hs.menubar.new()
end
-- sets title to be displayed in menubar (really doesn't have to be own func?)
function setResolutionDisplay(w)
  resolutionMenu:setTitle(tostring(w))
  resolutionMenu:setMenu(dropdownOptions)
end

-- When clicked, toggles through two most common resolutions by passing
-- key manually to process key function

-- this is kind of flawed because logic only works on desktop
-- where it toggles between gaming mode and non-gaming mode
-- maybe just make it a dropdown?
function resolutionClicked()
  local screen = hs.screen.primaryScreen()
  if screen:currentMode().w == 1920 then
    processKey("3")
  else
    processKey("1")
  end
end

-- sets callback and calls settitle function
if resolutionMenu then
  -- resolutionMenu:setClickCallback(resolutionClicked)
  local currentRes = hs.screen.primaryScreen():currentMode().w
  setResolutionDisplay(currentRes)
end




------------------------
-- Spaces
------------------------
-- Gets a list of windows and iterates until the window title is non-empty.
-- This avoids focusing the hidden windows apparently placed on top of all
-- Google Chrome windows. It also checks if the empty title belongs to Chrome,
-- because some apps don't give any of their windows a title, and should still
-- be focused.
local function spaceChange()
  makeStatsMenu("spaceChange")
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



-- Clean trash
-- hs.hotkey.bind(hyper, "t", function()
--    os.execute("/bin/rm -rf ~/.Trash/*")
-- end)

-- Spaces FIXME this does not work with multiple screens
--------------------------------------------------------------------------------
-- switch Spaces
hs.hotkey.bind(hyper, '1', function()
  spaces.changeToSpace("1", true)
  spaceChange()
end)
hs.hotkey.bind(hyper, '2', function()
  spaces.moveToSpace("2")
  spaceChange()
end)
hs.hotkey.bind(hyper, '3', function()
  spaces.moveToSpace("3")
  spaceChange()
end)
hs.hotkey.bind(hyper, '4', function()
  spaces.moveToSpace("4")
  spaceChange()
end)
hs.hotkey.bind(hyper, '5', function()
  spaces.moveToSpace("5")
  spaceChange()
end)
hs.hotkey.bind(hyper, '6', function()
  spaces.moveToSpace("6")
  spaceChange()
end)

function moveWindowOneSpace(direction)
   local mouseOrigin = hs.mouse.getAbsolutePosition()
   local win = hs.window.focusedWindow()
   local clickPoint = win:zoomButtonRect()

   clickPoint.x = clickPoint.x + clickPoint.w + 5
   clickPoint.y = clickPoint.y + (clickPoint.h / 2)

   local mouseClickEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftmousedown, clickPoint)
   mouseClickEvent:post()
   hs.timer.usleep(150000)

   local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, true)
   nextSpaceDownEvent:post()
   hs.timer.usleep(150000)

   local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, false)
   nextSpaceUpEvent:post()
   hs.timer.usleep(150000)

   local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint)
   mouseReleaseEvent:post()
   hs.timer.usleep(150000)

  hs.mouse.setAbsolutePosition(mouseOrigin)
  spaceChange()
end


hk1 = hs.hotkey.bind(hyper, "m",
             function() moveWindowOneSpace("right") end)
hk2 = hs.hotkey.bind(hyper, "n",
             function() moveWindowOneSpace("left") end)


--------------------------------------------------------------------------------


------------------------
-- Bluetooth
------------------------
-- relies on https://github.com/toy/blueutil
-- installable via `brew install blueutil`

function enableBluetooth()
  hs.alert.show("Enabling Bluetooth")
  os.execute("/usr/local/bin/blueutil power 1")
end

function disableBluetooth()
  hs.alert.show("Disabling Bluetooth")
  os.execute("/usr/local/bin/blueutil power 0")
end

function bluetoothEnabled()
  local file = assert(io.popen('/usr/local/bin/blueutil power', 'r'))
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
-- Network location
------------------------

function currentNetworkLocation()
  local file = assert(io.popen('/usr/sbin/networksetup -getcurrentlocation', 'r'))
  local output = file:read('*all')
  file:close()

  return output:gsub("%s+", "")
end

-- this function relies on a sudoers.d entry like
-- %Local  ALL=NOPASSWD: /usr/sbin/networksetup -switchtolocation "name"
function switchNetworkLocation(name)
  local location = currentNetworkLocation()
  if (location ~= name) then
    hs.alert.show("Switching location to " .. name)
    os.execute("sudo /usr/sbin/networksetup -switchtolocation \"" .. name .. "\"")
  end
end


------------------------
-- Watch network changes
------------------------

function enteredNetwork(old_ssid, new_ssid, token)
  if (old_ssid == nil and new_ssid ~= nil) then
    return string.find (string.lower(new_ssid), string.lower(token))
  end

  if (old_ssid ~= nil and new_ssid == nil) then
    return false
  end

  -- significantly change wifi
  -- checking if we more than changed network within environment
  if (old_ssid ~= nil and new_ssid ~= nil) then
    hs.alert.show("Changed Wifi")
    return (not (string.find(string.lower(old_ssid), string.lower(token)) and
                string.find(string.lower(new_ssid), string.lower(token))))
  end

  return false
end


function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    print("ssidChangedCallback: old:"..(lastSSID or "nil").." new:"..(newSSID or "nil"))
    if (newSSID ~= nil) then
      if (enteredNetwork(lastSSID, newSSID, workSSIDToken)) then
        enteredWork()
      end

      if (enteredNetwork(lastSSID, newSSID, homeSSIDToken)) then
        enteredHome()
      end
    end

    lastSSID = newSSID
end

--wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
--wifiWatcher:start()

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

hs.hotkey.bind(hyper, 'Escape', toggle_audio_output)

function spotify_pause()
   hs.alert.show("Pausing Spotify")
   hs.spotify.pause()
end

function spotify_play()
   hs.alert.show("Playing Spotify")
   hs.spotify.play()
end

function mute()
  local dev = hs.audiodevice.defaultOutputDevice()
  hs.alert.show("Mute")
  dev:setMuted(true)
end

-- no need, use function keys
--hs.hotkey.bind(hyper, 'm', mute)

-- Per-device watcher to detect headphones in/out
function audiodevwatch(dev_uid, event_name, event_scope, event_element)
  print(string.format("dev_uid %s, event_name %s, event_scope %s, event_element %s", dev_uid, event_name, event_scope, event_element))
  dev = hs.audiodevice.findDeviceByUID(dev_uid)
  if event_name == 'jack' then
    if dev:jackConnected() then
      if spotifyWasPlaying then
        spotify_play()
      end
    else
      spotifyWasPlaying = hs.spotify.isPlaying()
      if spotifyWasPlaying then
        spotify_pause()
      end
    end
  end
end

hs.audiodevice.current()['device']:watcherCallback(audiodevwatch):watcherStart()

------------------------
-- Power settings
------------------------

function powerChanged()
  local current = hs.battery.powerSource()

  if (current ~= powerSource) then
    powerSource = current
    if (powerSource == "AC Power") then
      switchedToCharger()
    else
      switchedToBattery()
    end
  end
end

--hs.battery.watcher.new(powerChanged):start()


------------------------
-- Environment settings
------------------------

function enteredHome()
  if (bluetoothEnabled()) then
    disableBluetooth()
  end

  switchNetworkLocation(homeLocation)
end

function enteredWork()
  if (not bluetoothEnabled()) then
    enableBluetooth()
  end

  switchNetworkLocation(workLocation)
  mute()
end

function switchedToBattery()
  hs.alert.show("Battery")
  disableBluetooth()
end

function switchedToCharger()
  hs.alert.show("Charging")
end


------------------------
-- Reload
------------------------

function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
currentSpace = tostring(spaces.currentSpace())
updateStats()
makeStatsMenu()
hs.alert.show("Config loaded")
