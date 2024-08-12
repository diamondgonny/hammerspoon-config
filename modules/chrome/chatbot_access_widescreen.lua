-- This script creates a shortcut for easy chatbot access widescreen in Google Chrome
-- It's only active within Google Chrome, and is disabled in other programs
local trans_func = require('modules.chrome.macro')

local chromeHotkey = nil

-- Function to enable the hotkey when Google Chrome is active
local function enableChromeHotkey()
    if not chromeHotkey then
        chromeHotkey = hs.hotkey.bind({"cmd", "ctrl"}, "k", function()
            if trans_func.isGoogleChromeActive() then
                trans_func.performKeySequenceForChatbot(2, true, 5000)
                trans_func.performKeySequenceForChatbot(4, true, 500000)
                trans_func.performKeySequenceForChatbot(1, true, 500000)
                trans_func.performKeySequenceForChatbot(2, false, 0)
            end
        end)
    end
end

-- Function to disable the hotkey when Google Chrome is not active
local function disableChromeHotkey()
    if chromeHotkey then
        chromeHotkey:delete()
        chromeHotkey = nil
    end
end

-- Watcher to monitor application switches
hs.application.watcher.new(function(appName, eventType)
    if appName == "Google Chrome" then
        if eventType == hs.application.watcher.activated then
            enableChromeHotkey()
        elseif eventType == hs.application.watcher.deactivated then
            disableChromeHotkey()
        end
    end
end):start()
