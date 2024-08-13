FRemap = require('foundation_remapping')
remapper = FRemap.new({vendorID=0x05ac, productID=0x024f})
remapper:remap(0x73, 'F14')
remapper:register()

local home_to_fn_f8

local function sendSystemKey(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

function play_pause()
    sendSystemKey("PLAY")
end

home_to_fn_f8 = hs.hotkey.new({}, 'F14', play_pause):enable()

