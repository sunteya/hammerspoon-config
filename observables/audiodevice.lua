local Rx = require "rx"
local audiodevice = require "hs.audiodevice"

local audiodeviceSubject = Rx.Subject.create()
local AudiodeviceObservable = {}

audiodevice.watcher.setCallback(function(type)
  audiodeviceSubject:onNext(type)
end)

audiodevice.watcher.start()

function AudiodeviceObservable.create()
  return audiodeviceSubject
end

return AudiodeviceObservable
