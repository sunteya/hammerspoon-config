-----------------------------------------------
-- Library
-----------------------------------------------
local hotkey = require "hs.hotkey"
local fnutils = require "hs.fnutils"


-----------------------------------------------
-- Keep Built-in audio output on AirPlay
-----------------------------------------------
local AirPlayWatcher = require "AirPlayWatcher"
local airPlayWatcher = AirPlayWatcher.create(function()
  local builtInAudioOut = hs.audiodevice.findOutputByName("Built-in Output")
  builtInAudioOut:setDefaultOutputDevice()
end)
airPlayWatcher:start()


-----------------------------------------------
-- Reload config on write
-----------------------------------------------
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")
