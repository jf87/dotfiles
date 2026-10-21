-- Cycle the display arrangement through three physical setups:
--   laptop left:  laptop on a stand to the left of the external display
--   laptop below: laptop in front of (below) the external display, centered
--   laptop right: laptop on a stand to the right of the external display
--
-- Only the non-primary screen can be moved, so the wanted offset between the
-- two screens is applied to whichever one that is.

local M = {}

local function screens()
  local builtin, external
  for _, s in ipairs(hs.screen.allScreens()) do
    if s:name():find("Built%-in") then builtin = s else external = s end
  end
  return builtin, external
end

function M.toggle()
  local builtin, external = screens()
  if not (builtin and external) then
    hs.alert.show("Displays: need laptop + one external")
    return
  end
  local b, e = builtin:fullFrame(), external:fullFrame()

  -- Wanted origin of the external display relative to the laptop's, picking
  -- the next setup in the cycle left -> below -> right -> left.
  local dx, dy, label
  if e.x >= b.x + b.w then                                -- currently laptop left
    dx, dy, label = (b.w - e.w) / 2, -e.h, "laptop below" -- centered underneath
  elseif e.y + e.h <= b.y then                            -- currently laptop below
    dx, dy, label = -e.w, b.h - e.h, "laptop right"       -- bottom edges aligned
  else
    dx, dy, label = b.w, b.h - e.h, "laptop left"         -- bottom edges aligned
  end
  dx, dy = math.floor(dx), math.floor(dy)

  local ok
  if builtin == hs.screen.primaryScreen() then
    ok = external:setOrigin(b.x + dx, b.y + dy)
  else
    ok = builtin:setOrigin(e.x - dx, e.y - dy)
  end
  hs.alert.show(ok and ("Displays: " .. label) or "Displays: arrangement failed")
end

return M
