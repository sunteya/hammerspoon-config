local screen = require "hs.screen"
local audiodevice = require "hs.audiodevice"
local timer = require "hs.timer"
local Rx = require "rx"

local Observables = require "observables"

local AirPlayWatcher = {}
AirPlayWatcher.__index = AirPlayWatcher

function AirPlayWatcher.create(onAirPlay)
  local self = {
    onAirPlay = onAirPlay
  }
  return setmetatable(self, AirPlayWatcher)
end

function AirPlayWatcher:stop()
  if (self.screenWatcher) then
    self.screenWatcher:stop()
    self.screenWatcher = nil
  end

  if (self.audiodeviceSubscription) then
    self.audiodeviceSubscription:unsubscribe()
    self.audiodeviceSubscription = nil
  end
end

function AirPlayWatcher:init()
  self.screenSubject = Rx.Subject.create()
  self.audioSubject = Rx.Subject.create()

  self.screenSubject:first():subscribe(function()
    self:waitTimeout()
  end)

  self.audioSubject:first():subscribe(function()
    self:waitTimeout()
  end)

  Rx.Observable.zip(self.screenSubject:first(), self.audioSubject:first()):subscribe(function()
    self:doOnAirPlay()
  end)
end

function AirPlayWatcher:doOnAirPlay()
  self.onAirPlay()
end

function AirPlayWatcher:waitTimeout()
  timer.doAfter(5, function()
    self:init()
  end)
end

function AirPlayWatcher:start()
  self:init()

  self.screenWatcher = screen.watcher.newWithActiveScreen(function(args)
    self.screenSubject:onNext("screen")
  end)
  self.screenWatcher:start()

  self.audiodeviceSubscription = Observables.audiodevice.create()
    :filter(function(t) return t == "dOut" end)
    :filter(function(t) return audiodevice.defaultOutputDevice():name() == "AirPlay" end)
    :subscribe(function(type)
        self.audioSubject:onNext("audio")
    end)
end

return AirPlayWatcher
