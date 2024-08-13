-- key mapping for vim
-- Convert input source as English and sends 'escape' if inputSource is not English
-- Sends 'escape' if inputSource is English
-- key binding reference --> https://www.hammerspoon.org/docs/hs.hotkey.html
-- defaults write -g InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)
-- defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

local inputEnglish = "com.apple.keylayout.ABC"
local esc_bind

function back_to_eng()
    local inputSource = hs.keycodes.currentSourceID()
    if inputSource ~= inputEnglish then
        -- hs.eventtap.keyStroke({}, 'right')
        hs.keycodes.currentSourceID(inputEnglish)
    end
    esc_bind:disable()
    hs.eventtap.keyStroke({}, 'escape')
    esc_bind:enable()
end

esc_bind = hs.hotkey.new({}, 'escape', back_to_eng):enable()
