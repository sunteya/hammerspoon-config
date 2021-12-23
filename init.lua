-----------------------------------------------
-- Library
-----------------------------------------------
local hotkey = require "hs.hotkey"
local fnutils = require "hs.fnutils"
local caffeinate = require "hs.caffeinate"


-----------------------------------------------
-- Keep Built-in audio output on AirPlay
-----------------------------------------------
local AirPlayWatcher = require "AirPlayWatcher"
AirPlayWatcher.create(function()
  local builtInDevice = nil
  for _, device in ipairs(hs.audiodevice.allOutputDevices()) do
    if (device:transportType() == "Built-in") then
      builtInDevice = device
      break
    end
  end

  builtInDevice:setDefaultOutputDevice()
end):start()


-----------------------------------------------
-- Keep wake quiet
-----------------------------------------------
caffeinate.watcher.new(function(event)
  if event == caffeinate.watcher.systemWillSleep then
    local device = hs.audiodevice.defaultOutputDevice()
    device:setVolume(20)
    print("Set " .. device:name() .. " volume to 20%")
  end
end):start()

-- caffeinate.watcher.new(function(event)
--   if event == caffeinate.watcher.systemDidWake then
--     hs.execute("ps aux | grep Jitouch | grep -v grep | awk '{print $2}' | xargs kill && open ~/Library/PreferencePanes/Jitouch.prefPane/Contents/Resources/Jitouch.app", true)
--   end
-- end):start()

-- caffeinate.watcher.new(function(event)
--   if event == caffeinate.watcher.screensaverDidStart then
--     print("caffeinate event screensaverDidStart")
--   elseif event == caffeinate.watcher.screensaverDidStop then
--     print("caffeinate event screensaverDidStop")
--   elseif event == caffeinate.watcher.screensaverWillStop then
--     print("caffeinate event screensaverWillStop")
--   elseif event == caffeinate.watcher.screensDidLock then
--     print("caffeinate event screensDidLock")
--   elseif event == caffeinate.watcher.screensDidSleep then
--     print("caffeinate event screensDidSleep")
--   elseif event == caffeinate.watcher.screensDidUnlock then
--     print("caffeinate event screensDidUnlock")
--   elseif event == caffeinate.watcher.screensDidWake then
--     print("caffeinate event screensDidWake")
--   elseif event == caffeinate.watcher.sessionDidBecomeActive then
--     print("caffeinate event sessionDidBecomeActive")
--   elseif event == caffeinate.watcher.sessionDidResignActive then
--     print("caffeinate event sessionDidResignActive")
--   elseif event == caffeinate.watcher.systemDidWake then
--     print("caffeinate event systemDidWake")
--   elseif event == caffeinate.watcher.systemWillPowerOff then
--     print("caffeinate event systemWillPowerOff")
--   elseif event == caffeinate.watcher.systemWillSleep then
--     print("caffeinate event systemWillSleep")
--   end
-- end):start()

-----------------------------------------------
-- Reload config on write
-----------------------------------------------
function reload_config(files)
  hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")



-- -----------------------------------------------
-- -- TEMPORARY!! Capslock is Hyper Key
-- -----------------------------------------------
-- local globals = {}

-- hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
--   -- print("key = ", event:getKeyCode())
--   -- print('flagsChanged!', hs.inspect(event))

--   if event:getFlags().fn then
--     globals.hypered = true
--   else
--     globals.hypered = false
--   end

--   return false
-- end):start()

-- hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
--   if event:getKeyCode() == 179 then
--     if hs.keycodes.currentSourceID() == "com.apple.keylayout.US" then
--       hs.keycodes.currentSourceID("im.rime.inputmethod.Squirrel.Rime")
--     else
--       hs.keycodes.currentSourceID("com.apple.keylayout.US")
--     end
--   end
-- end):start()

-- hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
--   if globals.hypered then
--     if event:getKeyCode() == hs.keycodes.map["b"] then
--       positionWindowLikeBrowser()
--       return true
--     elseif event:getKeyCode() == hs.keycodes.map["e"] then
--       positionWindowLikeExplorer()
--       return true
--     end
--   end
-- end):start()

-- hs.eventtap.keyStroke({}, "ESCAPE")

-- xyzzy = hs.hotkey.bind({}, "j",
--     function()
--       print(hs.eventtap.checkKeyboardModifiers())
--         if hs.eventtap.checkKeyboardModifiers().fn then
--           print("FN is DOWN!!!")
--         else
--             xyzzy:disable()
--             hs.eventtap.keyStroke({}, "j")
--             xyzzy:enable()
--         end
--     end
-- )


local hyper = {"⌘", "⌥", "⌃", "⇧"}


-----------------------------------------------
-- Device manager
-----------------------------------------------
hotkey.bind(hyper, "m", function()
  local defaultDevice = hs.audiodevice.defaultInputDevice()
  if defaultDevice:inputMuted() then
    for _, device in ipairs(hs.audiodevice.allInputDevices()) do
      device:setInputMuted(false)
    end
    hs.alert.show("🎙️ On")
  else
    for _, device in ipairs(hs.audiodevice.allInputDevices()) do
      device:setInputMuted(true)
    end
    hs.alert.show("🎙️ 🛑️️ Off")
  end
end)

-----------------------------------------------
-- Window manager
-----------------------------------------------
local window = require "hs.window"
window.animationDuration = 0

function positionWindowLikeBrowser()
  local win = window.focusedWindow()
  local screen = win:screen():frame()
  local frame = win:frame()
  frame.w = screen.w * 0.94
  frame.h = screen.h * 0.97
  frame.x = (screen.w - frame.w) / 2
  frame.y = (screen.h - frame.h) / 2 + screen.y
  win:setFrame(frame)
end
hotkey.bind(hyper, "b", function()
  positionWindowLikeBrowser()
end)


function positionWindowLikeExplorer()
  local win = window.focusedWindow()
  local screen = win:screen():frame()
  local frame = win:frame()
  frame.w = screen.w * 0.75
  frame.h = screen.h * 0.75
  win:setFrame(frame)
end
hotkey.bind(hyper, "e", function()
  positionWindowLikeExplorer()
end)

-----------------------------------------------
-- Window Tiling
-----------------------------------------------
-- local screen = require "hs.screen"
-- local hack = require "./hack"
-- local mash = {"⌘", "⌥", "⌃", "⇧"}
--
-- local tiling = hack.require('hs.tiling', "hs/tiling/init.lua", "return%s+tiling%s*$", [[
--   tiling.excluded = excluded
--   tiling.getSpace = getSpace
--   return tiling
-- ]])
--
-- hotkey.bind(mash, "c", function() tiling.cycleLayout() end)
-- hotkey.bind(mash, "j", function() tiling.cycle(1) end)
-- hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
-- hotkey.bind(mash, "space", function() tiling.promote() end)
-- hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)
--
-- -- If you want to set the layouts that are enabled
-- tiling.set('layouts', {
--   'main-vertical-variable', 'fullscreen'
-- })
--
-- local space = tiling.getSpace()
-- space.mainVertical = 0.6
--
-- hotkey.bind(mash, "f", function()
--   tiling.toggleFloat(center)
-- end)
--
-- hotkey.bind(hyper,"9", function()
--   tiling.adjustMainVertical(-0.05)
-- end)
--
-- hotkey.bind(hyper,"0", function()
--   tiling.adjustMainVertical(0.05)
-- end)
--
-- hotkey.bind(mash,"=", function()
--   tiling.setMainVertical(0.5)
-- end)
--
-- hotkey.bind(mash,"-", function()
--   tiling.setMainVertical(0.6)
-- end)


-- -----------------------------------------------
-- -- hyper d for left one half window
-- -----------------------------------------------
-- hs.hotkey.bind(hyper, "d", function()
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local screen = win:screen()
--     local max = screen:frame()
--
--     f.x = max.x
--     f.y = max.y
--     f.w = max.w / 2
--     f.h = max.h
--     win:setFrame(f)
-- end)
--
-- -----------------------------------------------
-- -- hyper g for right one half window
-- -----------------------------------------------
-- hs.hotkey.bind(hyper, "g", function()
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local screen = win:screen()
--     local max = screen:frame()
--
--     f.x = max.x + (max.w / 2)
--     f.y = max.y
--     f.w = max.w / 2
--     f.h = max.h
--     win:setFrame(f)
-- end)
--
-- -----------------------------------------------
-- -- hyper f for fullscreen
-- -----------------------------------------------
-- hs.hotkey.bind(hyper, "f", function()
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local screen = win:screen()
--     local max = screen:frame()
--
--     f.x = max.x
--     f.y = max.y
--     f.w = max.w
--     f.h = max.h
--     win:setFrame(f)
-- end)
--
-- -----------------------------------------------
-- -- hyper r for top left one quarter window
-- -----------------------------------------------
-- hotkey.bind(mash, "r", function()
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local screen = win:screen()
--     local max = screen:frame()
--
--     f.x = max.x
--     f.y = max.y
--     f.w = max.w / 2
--     f.h = max.h / 2
--     win:setFrame(f)
-- end)

-- -----------------------------------------------
-- -- hyper t for top right one quarter window
-- -----------------------------------------------
-- hotkey.bind(mash, "t", function()
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local screen = win:screen()
--     local max = screen:frame()
--
--     f.x = max.x + (max.w / 2)
--     f.y = max.y
--     f.w = max.w / 2
--     f.h = max.h / 2
--     win:setFrame(f)
-- end)

-- -----------------------------------------------
-- -- hyper v for bottom left one quarter window
-- -----------------------------------------------
-- hotkey.bind(mash, "v", nil, function()
--     local win = hs.window.focusedWindow()
--     local f = win:frame()
--     local screen = win:screen()
--     local max = screen:frame()
--
--     f.x = max.x + (max.w / 2)
--     f.y = max.y + (max.h / 2)
--     f.w = max.w / 2
--     f.h = max.h / 2
--     win:setFrame(f)
-- end)

-- -----------------------------------------------
-- -- hyper c for bottom right one quarter window
-- -----------------------------------------------
-- hotkey.bind(mash, "c", function()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--   local screen = win:screen()
--   local max = screen:frame()
--
--   f.x = max.x
--   f.y = max.y + (max.h / 2)
--   f.w = max.w / 2
--   f.h = max.h / 2
--   win:setFrame(f)
-- end)

-----------------------------------------------
-- Hyper i to show window hints
-----------------------------------------------
-- hotkey.bind(hyper, "i", function()
--   hs.hints.windowHints()
-- end)


-- hs.hotkey.bind({"cmd"}, "f6", function()
--   hs.alert.show("f6")
-- end)

-- tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
--   print(hs.inspect(event:getRawEventData()))
-- end)
-- tap:start()

-- hotkey.bind(hyper, "t", function()
--   print("start debug")
-- end)
