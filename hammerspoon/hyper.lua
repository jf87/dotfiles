-- HYPER
--
-- Caps Lock is remapped to F18 (com.local.KeyRemapping.plist).
-- Holding F18 enters this modal; bindings are added in init.lua.
-- Tapping F18 alone sends Escape.

local hyper = hs.hotkey.modal.new({}, nil)

local function enterHyperMode()
  hyper.triggered = false
  hyper:enter()
end

local function exitHyperMode()
  hyper:exit()
  if not hyper.triggered then
    hs.eventtap.keyStroke({}, 'ESCAPE')
  end
end

hs.hotkey.bind({}, 'F18', enterHyperMode, exitHyperMode)

return hyper
