-- Request Jamf Connect admin privileges from the menu bar.
--
-- Jamf Connect exposes no URL scheme or CLI for elevation, so we drive its
-- menu-bar item via System Events. This runs with Hammerspoon's Accessibility
-- trust. It clicks "Request admin privileges", then in the reason dialog
-- selects the terminal-command option and clicks Continue.
--
-- The reason label is the German string this managed Mac shows; match by name
-- (not position) so it survives reordering.

local M = {}

local REASON = "Um im Terminal einen Befehl mit höheren Rechten auszuführen"

local script = ([[
on run
  tell application "System Events"
    if not (exists process "Jamf Connect") then return "no-process"
    tell process "Jamf Connect"
      set clicked to false
      repeat with mb in menu bars
        repeat with mbi in menu bar items of mb
          try
            click mbi
            delay 0.3
            set req to (menu items of menu 1 of mbi whose name starts with "Request admin")
            if (count of req) > 0 then
              click item 1 of req
              set clicked to true
              exit repeat
            end if
            set active to (menu items of menu 1 of mbi whose name starts with "End Admin")
            key code 53 -- Escape: close this menu
            if (count of active) > 0 then return "already-admin"
          end try
        end repeat
        if clicked then exit repeat
      end repeat
      if not clicked then return "not-found"

      -- Wait for the reason dialog, pick the option, click Continue.
      repeat 40 times
        try
          repeat with w in windows
            if (exists radio button "%s" of w) then
              click radio button "%s" of w
              delay 0.2
              click button "Continue" of w
              return "requested"
            end if
          end repeat
        end try
        delay 0.25
      end repeat
      return "requested-no-dialog"
    end tell
  end tell
end run
]]):format(REASON, REASON)

function M.request()
  local ok, result = hs.osascript.applescript(script)
  if result == "requested" then
    hs.alert.show("Jamf: admin requested")
  elseif result == "requested-no-dialog" then
    hs.alert.show("Jamf: requested (dialog not found)")
  elseif result == "already-admin" then
    hs.alert.show("Jamf: already admin")
  elseif result == "no-process" then
    hs.alert.show("Jamf Connect not running")
  else
    hs.alert.show("Jamf: 'Request admin' not found")
  end
end

return M
